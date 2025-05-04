class_name NuclearBomb
extends Node2D
# Huge damage in large area 
@onready var nuke_vfx: SolarFlareVFX = $nukeVFX
@onready var nuke_sfx: AudioMEventInstance2D = $NukeSFX

@onready var damage_range: Area2D = $DamageRange
@onready var damage_range_collision: CollisionShape2D = $DamageRange/DamageRangeCollision



@export var damage : float = 500.0

func _ready() -> void:
	nuke_sfx.play()
	nuke_vfx.appear()
	await get_tree().create_timer(1.3,false).timeout
	damage_range_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.2,false).timeout
	
	for body in damage_range.get_overlapping_bodies():
		if body is Enemy:
			body.take_damage(damage)
	
	
	remove()
	
	
	
	
	
	

func remove()->void:
	
	if nuke_sfx.is_playing():
		await nuke_sfx.done
	
	if nuke_vfx.is_playing():
		await nuke_vfx.done
	
	
	queue_free()
