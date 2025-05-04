class_name WhirlwindVFX
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal done
var is_playing : bool = true

func _ready() -> void:
	animated_sprite_2d.play("default")
	animated_sprite_2d.modulate = Color(1,1,1,0)


func appear():
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(1,1,1,1), 0.25)

func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(1,1,1,0), 0.25)
	await tween.finished
	done.emit()
	is_playing = false
	#self.queue_free()
