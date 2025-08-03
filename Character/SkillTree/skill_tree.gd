extends Control

var pages = ["skill", "stats", "controls"]
var page_index = 0
var first = false

@export var continue_level: Button
@export var loop_text: Label
var points_needed = 0

func _ready() -> void:
	CharacterNerfs.clear_temp_nerfs()
	for page in pages_buttons.get_children():
		for skill in page.get_children():
			if skill is SkillNode:
				skill.connect_signal(self)
	if CharacterNerfs.first_tree && CharacterNerfs.campaign:
		CharacterNerfs.first_tree = false
		_first()
	else:
		if CharacterNerfs.campaign:
			points_needed = CharacterNerfs.get_points_needed()
			total_points.text = "0 / " + str(points_needed)
			if points_needed == 0:
				continue_level.disabled = false
		else:
			total_points.text = str(CharacterNerfs.score) + " / ?"
			continue_level.disabled = false
		$Next.show()
		$Prev.show()
		$Pages/SkillPage/Troll1.hide()
		$Pages/SkillPage/Troll2.hide()
	if CharacterNerfs.campaign:
		loop_text.text = "Loop: " + str(CharacterNerfs.loop) + " / 5"
	else:
		loop_text.text = "Loop: " + str(CharacterNerfs.loop) + " / ?"
	if CharacterNerfs.game_over:
		continue_level.disabled = false
		continue_level.text = "Home"
		# Need to fully disable delete, and also change total points text
		delete.disabled = true
		total_points.text = "Final Score : " + str(CharacterNerfs.score)

###################################3
# When its your first time, it forces you to delete invinci shield
func _first():
	first = true
	$Pages/SkillPage/Shield/InvinciShield.pressed.connect(_on_invinci_pressed)

func _on_invinci_pressed():
	$Pages/SkillPage/Troll1.hide()
	$Pages/SkillPage/Troll2.show()
	skill_cost.text = "Cost: Infinity"

func _on_delete_pressed() -> void:
	if first:
		$Pages/SkillPage/Troll2.hide()
		$Pages/SkillPage/Troll3.show()
		continue_level.disabled = false
		skill_info.hide()
		total_points.text = "Infinity / Infinity"
	else:
		skill_info.hide()
		if CharacterNerfs.campaign:
			current_points += skill_cost_num
			total_points.text = str(current_points) + " / " + str(points_needed)
			if current_points >= points_needed:
				continue_level.disabled = false
		else:
			CharacterNerfs.score += skill_cost_num
			total_points.text = str(CharacterNerfs.score) + " / ?"
		

####################################3



func _on_prev_pressed() -> void:
	page_index -= 1
	page_index = page_index % 4
	show_page()

func _on_next_pressed() -> void:
	page_index += 1
	page_index = page_index % 3
	show_page()

func show_page():
	for page in $Pages.get_children():
		page.hide()
	match pages[page_index]:
		"skill":
			$Pages/SkillPage.show()
		"stats":
			$Pages/StatsPage.show()
		"passive":
			$Pages/PassivePage.show()
		"controls":
			$Pages/ControlsPage.show()

@export var pages_buttons : Control

@export var skill_info : VBoxContainer
@export var skill_name : Label
@export var skill_desc : Label
@export var skill_cost : Label
@export var total_points : Label

@export var base_damage : Label
@export var cooldown : Label
var skill_cost_num : int
var current_points = 0

var clicked_skill : SkillNode

@export var delete : Button
func skill_pressed(skill):
	if clicked_skill:
		clicked_skill.clicked_off()
	clicked_skill = skill
	for conn in delete.get_signal_connection_list("pressed"):
		delete.disconnect("pressed", conn.callable)
	delete.pressed.connect(_on_delete_pressed)
	skill_info.show()
	skill_name.text = skill.skill_name
	skill_desc.text = skill.skill_desc
	skill_cost_num = skill.skill_cost
	skill_cost.text = "Cost: " + str(skill_cost_num)
	if skill.base_damage:
		base_damage.text = "Base Damage : " + skill.base_damage
	else:
		base_damage.text = ""
	if skill.cooldown:
		cooldown.text = "Cooldown : " + skill.cooldown
	else:
		cooldown.text = ""
	if skill.is_highest_node():
		delete.disabled = false
		delete.pressed.connect(skill.remove)
	else:
		delete.disabled = true
	if CharacterNerfs.game_over:
		delete.disabled = true

func _on_clickoff_pressed() -> void:
	skill_info.hide()
	for conn in delete.get_signal_connection_list("pressed"):
		delete.disconnect("pressed", conn.callable)
	if clicked_skill:
		clicked_skill.clicked_off()

func _on_continue_pressed() -> void:
	if CharacterNerfs.game_over:
		get_tree().change_scene_to_file("res://Menus/HomeScene.tscn")
		return
	get_tree().change_scene_to_file("res://Stages/Level.tscn")
