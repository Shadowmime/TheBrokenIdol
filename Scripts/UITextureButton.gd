extends TextureButton
class_name UITextureButton

var original_scale: Vector2

@export var hover_modulate: Color = Color(1.2, 1.2, 1.2, 1)
@export_range(1, 2) var scale_mod: float = 1.05

func _ready():
	pivot_offset = get_centre()
	original_scale = scale
	
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	#connect("pressed", _on_pressed)

func get_centre() -> Vector2:
	var texture_size := texture_normal.get_size()
	var middle_point = texture_size / 2
	return middle_point

func _on_mouse_entered():
	if disabled:
		return
	self_modulate = hover_modulate
	scale = original_scale * scale_mod

func _on_mouse_exited():
	if disabled:
		return
	self_modulate = Color(1, 1, 1, 1)
	scale = original_scale

#func _on_pressed():
	#AudioManager.play_sound(1, click_sound, click_volume, click_pitch_range)
