class_name BossPart
extends Enemy

# — Part identification & spawn area —
enum PartType { LEFT_HAND, HEAD, RIGHT_HAND }

@export var part_type: PartType
@export var spawn_area: Area2D

# — Timing (tweak per‑part in Inspector) —
@export var windup_time: float   = 1.5

# — Signal to tell BossController we’re done —
signal attack_finished
signal part_dead(part_type)

var attack_cycle_count := 0
@export var teleport_every := 2  # Only teleport every 3 cycles

@export var base_cooldown: float = 5.0
@export var min_cooldown: float = 1.0
@export var cooldown_decay: float = 0.5

func _ready() -> void:
	# Initialize as an Enemy but disable its default movement FSM
	init()
	set_physics_process(false)
	
	detection_range.monitoring = false  # Boss parts do not auto‑detect
	hurt_box.monitoring = false

func _on_damage_rate_timeout() -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func get_current_cooldown() -> float:
	return max(min_cooldown, base_cooldown - attack_cycle_count * cooldown_decay)

func start_attack() -> void:
	# Teleport immediately
	if attack_cycle_count % teleport_every == 0:
		teleport_to_random_position()
	attack_cycle_count += 1
	
	# Wind‑up delay
	await get_tree().create_timer(windup_time).timeout
	
	# Do the part’s unique attack
	_perform_attack()
	
	# Cooldown before signaling
	await get_tree().create_timer(get_current_cooldown()).timeout
	emit_signal("attack_finished")

func _perform_attack() -> void:
	match part_type:
		PartType.LEFT_HAND:
			do_left_punch()
		PartType.HEAD:
			do_head_stun()
		PartType.RIGHT_HAND:
			do_raise_dead()

# — Default stubs; each part script can override these if desired — 
func do_left_punch() -> void:
	$HurtBox.monitoring = true
	for b in $HurtBox.get_overlapping_bodies():
		if b is PlayerUnit:
			b.take_damage(damage)
			apply_knockback(global_position, 0.2, 300.0)
	$HurtBox.monitoring = false

func do_head_stun():
	for u in get_tree().get_nodes_in_group("player_units"):
		u.apply_stun(1.5)

func do_raise_dead():
	# spawn_minions()
	pass

# Teleportation inside the CollisionPolygon2D of spawn_area
func teleport_to_random_position() -> void:
	if not spawn_area:
		return
	global_position = get_random_point_in_polygon(spawn_area)
	if has_node("TeleportEffect"):
		$TeleportEffect.play()

func get_random_point_in_polygon(area: Area2D) -> Vector2:
	var cp := area.get_node("CollisionPolygon2D") as CollisionPolygon2D
	var poly := cp.polygon
	
	# compute bounds
	var min_x = poly[0].x; var max_x = poly[0].x
	var min_y = poly[0].y; var max_y = poly[0].y
	
	for v in poly:
		min_x = min(min_x, v.x)
		max_x = max(max_x, v.x)
		min_y = min(min_y, v.y)
		max_y = max(max_y, v.y)
	
	var bounds = Rect2(
		Vector2(min_x, min_y),
		Vector2(max_x - min_x, max_y - min_y)
	)
	
	for i in range(20):
		var local = Vector2(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		)
		if Geometry2D.is_point_in_polygon(local, poly):
			return cp.to_global(local)
	return cp.global_position




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
	part_dead.emit(part_type)
	queue_free()
