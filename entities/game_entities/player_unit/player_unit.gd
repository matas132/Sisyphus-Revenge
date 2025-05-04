class_name PlayerUnit
extends BaseEntity

# — node refs —
@onready var health_bar: HealthBar     = $HealthBar
@onready var damage_rate_timer: Timer = $DamageRate
@onready var hurt_box: Area2D         = $HurtBox
@onready var detection_range: Area2D  = $DetectionRange
@onready var castle = get_tree().get_first_node_in_group("player_castle") as Node2D
@onready var react_timer: Timer = $ReactTimer
@onready var sprite: UnitGraphics = $Sprite

@onready var self_collider: CollisionShape2D = $CollisionShape2D
@onready var detect_collider: CollisionShape2D = $DetectionRange/CollisionShape2D
@onready var hurt_collider: CollisionShape2D = $HurtBox/CollisionShape2D



# FSM
enum State { ROAM, ATTACK }
var state: State = State.ROAM
var current_state: String = "roaming"

# Roam / Defend / Attack
var defend_radius: float = 300.0
var patrol_target: Vector2 = Vector2.ZERO
var target_enemy: Enemy = null

# Special Effects
var is_stunned: bool = false
var knockback_time_remaining: float = 0.0
var knockback_vector: Vector2 = Vector2.ZERO
var extra_velocity: Vector2 = Vector2.ZERO
var castle_direction: Vector2

# Stats
@export var damage_rate : float = 0.5
@export var damage : float = 20.0
@export var speed : float = 40

@export var animation_attack_delay : float = 0.0
# Direction Variables
var direction : Vector2

var recently_attacked := false

func _ready():
	init()
	set_physics_process(true)

func init() -> void:
	health = max_health
	health_bar.init(max_health)
	health_bar.update_health_bar(health)
	
	damage_rate_timer.start(damage_rate)
	castle_direction = (castle.global_position - global_position).normalized()
	
	if !health_changed.is_connected(on_health_changed):
		health_changed.connect(on_health_changed)
	

func _physics_process(delta: float) -> void: # probably better not to put too many things in the process function
	
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide(); return
	
	# state logic
	match state:
		State.ROAM:           _state_roam()
		State.ATTACK:         _state_attack(delta)
	
	# move
	velocity = speed * direction  + extra_velocity
	move_and_slide()

# ─── ROAM (Defend) ────────────────────────────────────────────────────────────
func _enter_roam():
	current_state = "roaming"
	patrol_target = global_position + Vector2(randf_range(-1,1), randf_range(-1,1)) * 100
	play_walk_anim()
	
func _state_roam():
	if patrol_target and global_position.distance_to(patrol_target) < 10:
		_enter_roam()
	elif patrol_target:
		direction = (patrol_target - global_position).normalized()
	else:
		direction = Vector2.ZERO
	
	# switch to ATTACK as soon as anyone shows up
	if _detect_enemy():
		state = State.ATTACK
		_enter_attack()

# ─── ATTACK ───────────────────────────────────────────────────────────────────
func _enter_attack():
	current_state = "attacking"
	target_enemy = _get_closest_enemy()
	play_attack_anim(target_enemy)

func _state_attack(delta):
	if not is_instance_valid(target_enemy) or _out_of_detection(target_enemy):
		state = State.ROAM
		_enter_roam()
		return
	
	attack_target(delta)

func attack_target(_delta):
	direction = (target_enemy.global_position - global_position).normalized()

# ─── UTILS & POLLING ──────────────────────────────────────────────────────────
func _detect_enemy() -> bool:
	for b in detection_range.get_overlapping_bodies():
		if b is Enemy:
			target_enemy = b
			return true
	target_enemy = null
	return false

func _get_closest_enemy() -> Enemy:
	var best_enemy : Enemy = null
	var best_dist = INF
	for b in detection_range.get_overlapping_bodies():
		if b is Enemy:
			var d = global_position.distance_to(b.global_position)
			if d < best_dist:
				best_dist = d
				best_enemy = b
	
	return best_enemy

func _random_point_on_circle(center: Vector2, radius: float) -> Vector2:
	var angle = randf_range(PI, TAU)
	return center + Vector2(cos(angle), sin(angle)) * radius

func _out_of_detection(e: Enemy) -> bool:
	return not detection_range.get_overlapping_bodies().has(e)

func _on_damage_rate_timeout() -> void:
	for body in hurt_box.get_overlapping_bodies():
		if body is Enemy:
			
			if is_stunned:
				return
			
			play_attack_anim(body)
			play_attack_wind_up()
			await get_tree().create_timer(animation_attack_delay,false).timeout
			if body:
				body.take_damage(damage)
			play_attack_sound()

# ─── DEBUFFS ──────────────────────────────────────────────────────────────────
func apply_stun(duration: float) -> void:
	if is_stunned:
		return
	
	#print("node" + self.name + "stunned")
	#play_idle_anim()
	on_stunned()
	is_stunned = true
	velocity = Vector2.ZERO
	
	await get_tree().create_timer(duration).timeout
	on_unstunned()
	is_stunned = false

func on_stunned()->void:
	return

func on_unstunned()->void:
	return


func apply_knockback(enemy_position: Vector2, duration: float = 0.1, strength: float = 220.0) -> void:
	var knockback_dir = (global_position - enemy_position).normalized()
	extra_velocity += knockback_dir * strength
	
	await get_tree().create_timer(duration).timeout
	extra_velocity = Vector2.ZERO

func set_extra_velocity(new_vel : Vector2)->void:
	extra_velocity = new_vel

func _hit_by_projectile(projectile_position : Vector2):
	var incoming_direction = (global_position - projectile_position).normalized()
	respond_to_projectile(incoming_direction)

func respond_to_projectile(incoming_direction : Vector2):
	if state != State.ATTACK and not recently_attacked:
		recently_attacked = true
		direction = -incoming_direction # Move toward source
		patrol_target = global_position + direction * 100
		_enter_roam()  # Optional: refresh roaming logic
		react_timer.start()

func _on_react_timeout():
	recently_attacked = false

func _on_detection_range_body_entered(body: Node2D) -> void:
	if body is Enemy and state != State.ATTACK:
		target_enemy = body
		state = State.ATTACK
		_enter_attack()
	
	if body is Castle and state != State.ATTACK:
		state = State.ROAM
		_enter_roam()

func _on_detection_range_body_exited(_body: Node2D) -> void:
	await get_tree().process_frame
	_get_closest_enemy()


func play_walk_anim()->void:
	if !dead:
		sprite.walk()


func play_attack_anim(body)->void:
	if dead:
		return
	var dir : Vector2 = global_position.direction_to(body.global_position)
	if dir.x > 0:
		sprite.scale.x = -abs(sprite.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)
	sprite.attack()



var dead : bool = false

func die()->void:
	self_collider.set_deferred("disabled", true)
	hurt_collider.set_deferred("disabled", true)
	detect_collider.set_deferred("disabled", true)
	speed = 0.0
	dead = true
	await get_tree().physics_frame
	
	sprite.die()
	await get_tree().create_timer(1.5).timeout
	
	
	
	died.emit()
	queue_free()

func play_idle_anim()->void:
	if dead:
		return
	
	sprite.idle()
	

func play_attack_sound()->void:
	return

func on_health_changed()->void:
	health_bar.update_health_bar(health)
	if health <= max_health/2:
		on_half_health()


func on_half_health()->void:
	pass

func play_attack_wind_up()->void:
	return
