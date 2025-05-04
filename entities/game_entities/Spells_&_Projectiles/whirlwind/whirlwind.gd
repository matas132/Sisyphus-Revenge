extends Node2D
##whirlwind: spawns in a hurricane and the hurricane slowly moves in a random direction for a few seconds and knocks back all entities and deals damage to them 

var direction : Vector2 = Vector2.ZERO

@export var speed : float = 80.0
@export var damage : float = 30.0

@export var duration : float = 20.0
@export var duration_reset : float = 3.0

@onready var damage_area_collision: CollisionShape2D = $DamageArea/DamageAreaCollision

@onready var change_direction: Timer = $ChangeDirection
@onready var duration_timer: Timer = $Duration

@onready var suck_in_area: Area2D = $SuckInArea
@onready var suck_in_area_collision: CollisionShape2D = $SuckInArea/SuckInAreaCollision

@onready var whirlwind_vfx: WhirlwindVFX = $Whirlwind
@onready var whirlwind_sound: AudioMEventInstance2D = $WhirlwindSound

var max_travel_distance : float = 3000.0

func _ready() -> void:
	visible = false
	await get_tree().process_frame
	global_position.y +=50
	damage_area_collision.set_deferred("disabled", false)
	suck_in_area_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	visible = true

	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0) 
	
	direction = Vector2(x, y) 
	
	change_direction.start(duration_reset)
	duration_timer.start(duration)
	
	whirlwind_vfx.appear()
	whirlwind_sound.play()

func _physics_process(delta: float) -> void:
	position += delta * direction * speed
	
	
	if max_travel_distance < (get_tree().get_first_node_in_group("player_castle").global_position.distance_to(global_position)):
		remove()
		
		
		
	



func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
		body.apply_knockback(global_position,0.3,510)
	#elif body is PlayerUnit:
	#	body.apply_knockback(global_position,0.3,300)


func remove()->void:
	whirlwind_vfx.disappear()
	whirlwind_sound.stop()
	
	
	if whirlwind_vfx.is_playing:
		await whirlwind_vfx.done
	
	if whirlwind_sound.is_playing():
		await whirlwind_sound.done
	
	
	queue_free()


func _on_change_direction_timeout() -> void:
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0) 
	
	direction = Vector2(x, y) 
	


func _on_duration_timeout() -> void:
	remove()


func _on_suck_in_area_body_entered(_body: Node2D) -> void:
	pass
	# TODO suck in enemies
	
	#if body is Enemy:
	#	body.direction += (body.global_position.direction_to(global_position)).normalized()



func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body is Wall:
		direction = direction * -1
		
		
