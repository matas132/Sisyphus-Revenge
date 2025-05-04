extends Node2D

@onready var whirlpool_area: Area2D = $WhirlpoolArea
@onready var whirlpool_area_collision: CollisionShape2D = $WhirlpoolArea/WhirlpoolAreaCollision
@onready var dur_timer: Timer = $DurTimer
@onready var pool_vfx: WhirlpoolVFX = $PoolVFX
@onready var pool_sfx: AudioMEventInstance2D = $PoolSFX


@export var damage :float = 110.0

@export var duration : float = 7.0

func _ready() -> void:
	dur_timer.start(duration)
	
	whirlpool_area_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	
	pool_sfx.play()
	pool_vfx.appear()
	






func remove()->void:
	pool_sfx.stop()
	pool_vfx.disappear()
	
	if pool_vfx != null:
		await pool_vfx.done
	
	if pool_sfx.is_playing():
		await pool_sfx.done
	
	queue_free()


func _on_dur_timer_timeout() -> void:
	whirlpool_area_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	for body in whirlpool_area.get_overlapping_bodies():
		if body.has_method("set_extra_velocity"):
			body.set_extra_velocity(Vector2.ZERO)
			if body is Enemy:
				body.take_damage(damage)
			
	
	remove()


func _on_update_timer_timeout() -> void:
	for body in whirlpool_area.get_overlapping_bodies():
		if body.has_method("set_extra_velocity"):
			body.set_extra_velocity(body.global_position.direction_to(global_position) *100)
			
