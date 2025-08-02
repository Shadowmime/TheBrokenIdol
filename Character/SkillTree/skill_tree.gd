extends Control

var pages = ["skill", "stats", "passive", "controls"]
var page_index = 0

func _on_prev_pressed() -> void:
	page_index -= 1
	page_index = page_index % 4
	show_page()

func _on_next_pressed() -> void:
	page_index += 1
	page_index = page_index % 4
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

func _ready() -> void:
	for page in pages_buttons.get_children():
		for skill in page.get_children():
			skill.connect_signal(self)

@export var skill_info : VBoxContainer
@export var skill_name : Label
@export var skill_desc : Label

@export var delete : Button
func skill_pressed(skill):
	for conn in delete.get_signal_connection_list("pressed"):
		delete.disconnect("pressed", conn.callable)
	skill_info.show()
	skill_name.text = skill.skill_name
	skill_desc.text = skill.skill_desc
	if skill.is_highest_node():
		delete.disabled = false
		delete.pressed.connect(skill.remove)
	else:
		delete.disabled = true

func _on_clickoff_pressed() -> void:
	skill_info.hide()
	for conn in delete.get_signal_connection_list("pressed"):
		delete.disconnect("pressed", conn.callable)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Stages/Level.tscn")
