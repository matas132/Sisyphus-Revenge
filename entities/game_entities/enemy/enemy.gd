class_name Enemy
extends BaseEntity

@onready var sprite = $Sprite

@onready var health_bar: HealthBar = $HealthBar
@onready var detection_range: Area2D = $DetectionRange
@onready var damage_rate_timer: Timer = $DamageRate
@onready var hurt_box: Area2D = $HurtBox

@export var damage_rate : float = 0.5
@export var damage : float = 20.0

var castle_direction : Vector2
@export var default_speed : float = 100.0


@onready var self_collider: CollisionShape2D = $CollisionShape2D
@onready var detection_collider: CollisionShape2D = $DetectionRange/CollisionShape2D
@onready var hurt_collider: CollisionShape2D = $HurtBox/CollisionShape2D

@export var animation_attack_delay : float = 0.0


var speed : float
var direction : Vector2

var is_stunned: bool = false

var knockback_time_remaining: float = 0.0
var knockback_vector: Vector2 = Vector2.ZERO

var extra_velocity : Vector2 = Vector2.ZERO

var debuffed : bool = false # by fire or by poison

func init()->void:
	castle_direction = (get_tree().get_first_node_in_group("player_castle").global_position - global_position).normalized()
	damage_rate_timer.start(damage_rate)
	speed = default_speed
	direction = castle_direction
	
	health = max_health
	health_bar.init(max_health)
	health_bar.update_health_bar(health)
	
	#health_changed.connect(func(): health_bar.update_health_bar(health))
	if sprite != null:
		sprite.idle()
	
	
	if !health_changed.is_connected(on_health_changed):
		health_changed.connect(on_health_changed)

func _physics_process(_delta: float) -> void: # probably better not to put too many things in the process function
	
	if is_stunned:
		
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	velocity = speed * direction + extra_velocity
	
	
	move_and_slide()


func _on_detection_range_body_entered(_body: Node2D) -> void:
	
	check_detected_bodies()



func _on_damage_rate_timeout() -> void:
	for overlapping_body in hurt_box.get_overlapping_bodies():
		if overlapping_body is BaseEntity && !(overlapping_body is Enemy):
			var body : BaseEntity = overlapping_body 
			
			if is_stunned:
				return
			
			#print("body detected")
			
			play_attack_anim(body)
			play_attack_wind_up()
			await get_tree().create_timer(animation_attack_delay,false).timeout
			#print("dealing damage")
			body.take_damage(damage)
			play_attack_sound()

func _on_detection_range_body_exited(_body: Node2D) -> void:
	await get_tree().process_frame
	check_detected_bodies()

func check_detected_bodies()->void:
	for overlapping_body in detection_range.get_overlapping_bodies():
		if overlapping_body is PlayerUnit:
			var detected_pl_unit : PlayerUnit = overlapping_body
			direction = (detected_pl_unit.global_position - global_position).normalized()
			play_walk_anim()
			return
	play_walk_anim()
	
	direction = castle_direction

func apply_stun(duration: float) -> void:
	if is_stunned:
		return
	sprite.idle()
	
	is_stunned = true
	velocity = Vector2.ZERO
	play_idle_anim()
	await get_tree().create_timer(duration).timeout
	is_stunned = false

func apply_knockback(enemy_position: Vector2, duration: float = 0.1, strength: float = 220.0) -> void:
	var knockback_dir = (global_position - enemy_position).normalized()
	extra_velocity += knockback_dir * strength
	sprite.idle()
	await get_tree().create_timer(duration).timeout
	extra_velocity = Vector2.ZERO

func set_extra_velocity(new_vel : Vector2)->void:
	extra_velocity = new_vel


func die()->void:
	
	
	speed = 0.0
	extra_velocity = Vector2.ZERO
	
	self_collider.set_deferred("disabled", true)
	detection_collider.set_deferred("disabled", true)
	hurt_collider.set_deferred("disabled", true)
	
	await get_tree().create_timer(0.1).timeout
	
	sprite.die()
	await get_tree().create_timer(1.5).timeout
	died.emit()
	queue_free()

func play_attack_anim(body : BaseEntity)->void:
	var dir : Vector2 = global_position.direction_to(body.global_position)
	if dir.x > 0:
		sprite.scale.x = -abs(sprite.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)
	sprite.attack()
	

func play_walk_anim()->void:
	if speed !=0.0:
		sprite.walk()

func play_idle_anim()->void:
	if speed !=0.0:
		sprite.idle()



func take_damage(taken_damage : float)->void:
	if taken_damage < 9000.0:
		@warning_ignore("narrowing_conversion")
		GlobalVar.GameState.score+= taken_damage
		
		
		var vfx_text : VFXtext = VFXtext.new()
		vfx_text.text = str(taken_damage)
		vfx_text.position = global_position + Vector2(randf_range(-40,40),-60)
		vfx_text.fade_time = 1.5
		vfx_text.font_size = 40
		vfx_text.font_color = Color("c8a600")
		vfx_text.font = load("res://assets/font/AntroposFreefont-BW2G.ttf")
		vfx_text.rotation = randf_range(-20,20)
		EventHandler.create_text.emit(vfx_text)
		
		
	elif taken_damage > 9000.0:
		
		
		var vfx_text : VFXtext = VFXtext.new()
		vfx_text.text = str("∞")
		vfx_text.position = global_position + Vector2(randf_range(-40,40),-60)
		vfx_text.fade_time = 1.5
		vfx_text.font_size = 90
		vfx_text.font_color = Color("8c1d00")
		vfx_text.font = load("res://assets/font/new_system_font.tres")
		vfx_text.rotation = randf_range(-10,10)
		EventHandler.create_text.emit(vfx_text)
		
		
		
		
		
		
	
	
	health = clampf(health- taken_damage, 0, max_health)
	
	health_changed.emit()
	if health <=0:
		die()


func play_attack_sound()->void:
	return

func play_attack_wind_up()->void:
	return

func on_half_health()->void:
	pass

func on_health_changed()->void:
	health_bar.update_health_bar(health)
	if health <= max_health/2:
		on_half_health()
