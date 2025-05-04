class_name WhirlpoolVFX
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal done


func appear():
	animation_player.play("appear")


func disappear():
	animation_player.play("disappear")
	await animation_player.animation_finished
	done.emit()
	self.queue_free()
