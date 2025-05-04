extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D


func idle():
	animation_player.play("idle")

func walk():
	animation_player.play("walk")

func attack():
	animation_player.play("attack")

func die():
	animation_player.play("die")
