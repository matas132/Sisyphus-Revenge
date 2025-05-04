class_name UnitGraphics
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var orig_sprite_texture : Texture2D = sprite_2d.texture

func idle():
	animation_player.play("idle")

func walk():
	animation_player.play("walk")

func attack():
	animation_player.play("attack")

func die():
	animation_player.play("die")

func default_texture()->void:
	sprite_2d.texture = orig_sprite_texture

func set_new_sprite_texture(new_texture :Texture2D)->void:
	sprite_2d.texture = new_texture
	orig_sprite_texture = new_texture
