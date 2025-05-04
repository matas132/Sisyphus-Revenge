extends Node2D

@export var damage :float = 70.0

@onready var blade_storm_damage_collision: CollisionShape2D = $BladeStormArea/BladeStormDamageCollision
@onready var blade_storm_area: Area2D = $BladeStormArea


func _ready() -> void:
	await get_tree().create_timer(0.9,false).timeout
	
	blade_storm_damage_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	
	for body in blade_storm_area.get_overlapping_bodies():
		if body is Enemy:
			body.take_damage(damage)
	remove()
	
	

func remove()->void:
	queue_free()
