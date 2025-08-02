extends TextureButton
class_name SkillNode

@export var panel : Panel
signal node_pressed(node: SkillNode)

func _ready() -> void:
	if get_parent() is SkillNode:
		line.add_point(global_position + size/2)
		line.add_point(get_parent().global_position + size/2)
	if skill_sprite:
		texture_normal = skill_sprite

func _on_pressed() -> void:
	panel.show()
	node_pressed.emit(self)

@export var skill_name : String
@export var skill_cost : int
@export var line : Line2D
@export var skill_sprite : Texture
@export var skill_desc : String
@export var skill_reference : String

@export var delete_button : Button

func connect_signal(controller):
	node_pressed.connect(controller.skill_pressed)
	for child in get_children():
		if child.has_method("connect_signal"):
			child.connect_signal(controller)
	if CharacterNerfs.has_nerf(skill_reference):
		queue_free()

func remove():
	CharacterNerfs.add_nerf(skill_reference)
	$AnimationPlayer.play("delete")
	await get_tree().create_timer(0.5).timeout
	queue_free()

func is_highest_node() -> bool:
	for child in get_children():
		if child is SkillNode:
			return false
	return true

func clicked_off():
	$Panel.hide()
