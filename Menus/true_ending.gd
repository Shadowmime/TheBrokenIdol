extends Node2D

@export var anim_player: AnimationPlayer
@export var music_player: AudioStreamPlayer

func _ready() -> void:
	anim_player.animation_finished.connect(on_animation_finished)
	anim_player.play("fadeinlabels")
	
	#music_player.play()

func on_animation_finished(anim_name: String):
	if anim_name == "fadeinlabels":
		music_player.play()
