extends Node2D

@onready var black_hole_area: Area2D = $BlackHoleArea
@onready var black_hole_collision: CollisionShape2D = $BlackHoleArea/BlackHoleCollision

@export var damage :float = 9999.0

@onready var black_hole_sfx: AudioMEventInstance = $BlackHoleSFX


func _ready() -> void:
	black_hole_sfx.play()
	await get_tree().create_timer(2.5,false).timeout
	
	black_hole_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	
	for body in black_hole_area.get_overlapping_bodies():
		if body is Enemy && !(body is BossPart): # TODO, if enemy issnt chaos, don't damage
			body.take_damage(damage)
	remove()
	
	

func remove()->void:
	
	if black_hole_sfx.is_playing():
		await black_hole_sfx.done
	
	queue_free()
