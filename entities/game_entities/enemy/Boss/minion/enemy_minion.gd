class_name EnemyMinion
extends Enemy

const DAMAGED = preload("res://assets/Entities/Enemy units/half_health/GameJam-ControlledChaos-Unit-Enemy-Zombie-Damaged.png")

func _ready() -> void:
	
	init()


func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)
