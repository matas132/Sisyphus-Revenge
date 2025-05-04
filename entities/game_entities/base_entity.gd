class_name BaseEntity
extends CharacterBody2D
# for inheritance, has health functions

@export var max_health : float
@export var health : float


signal health_changed
signal died

func die()->void:
	died.emit()
	queue_free()

func take_damage(damage : float)->void:
	
	
	
	health = clampf(health- damage, 0, max_health)
	
	health_changed.emit()
	if health <=0:
		die()
	
	
	
	
