class_name SolarFlareVFX
extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal done

func appear()->void:
	animation_player.play("explode")
	

func is_playing()->bool:
	return animation_player.is_playing()



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		done.emit()
