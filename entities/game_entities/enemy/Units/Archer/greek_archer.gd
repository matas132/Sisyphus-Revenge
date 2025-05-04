class_name GreekArcher
extends Enemy

@export var projectile_scene : PackedScene
@export var ranged_damage : float = 3.0
@export var preferred_distance : float = 200.0
@onready var attack_sound: AudioMEventInstance2D = $AttackSound

const DAMAGED = preload("res://assets/Entities/Enemy units/half_health/GameJam-ControlledChaos-Unit-Enemy-Toxotes-Damaged-Small.png")

func _ready() -> void:
	
	
	init()

func _physics_process(_delta: float) -> void:
	# 1) Find nearest PlayerUnit in range
	var target = get_closest_enemy()
	if target:
		var to_target = target.global_position - global_position
		var dist = to_target.length()
		
		# 2) Keep preferred firing distance
		if dist < preferred_distance:
			direction = -to_target.normalized()
		elif dist > preferred_distance * 1.2:
			direction = to_target.normalized()
		else:
			direction = Vector2.ZERO
		
		# 3) Fire a shot if ready
		attack_enemy(target)
	
	else:
		# no one in sight → continue toward the castle
		direction = castle_direction
	
	# 4) Let the base class handle movement, knockback, stuns, etc.
	super._physics_process(_delta)


func get_closest_enemy() -> Node:
	# Search in the detection range for player units (or other relevant targets)
	var best_unit: BaseEntity = null
	var best_dist = INF
	for body in detection_range.get_overlapping_bodies():
		if (body is PlayerUnit or body.is_in_group("player_castle")):
			var d = global_position.distance_to(body.global_position)
			if d < best_dist:
				best_dist = d
				best_unit = body
	return best_unit

func attack_enemy(enemy: Node) -> void:
	if not damage_rate_timer.is_stopped():
		return
	
	#print("Archer is attacking ", enemy.name)
	
	# draw the timer
	damage_rate_timer.start(damage_rate)
	
	# spawn & configure projectile
	var proj = projectile_scene.instantiate()
	
	
	#get_tree().current_scene.add_child(proj)
	get_parent().call_deferred("add_child",proj)
	await get_tree().process_frame
	proj.global_position = global_position
	#proj.look_at(enemy.global_position)
	
	
	
	play_attack_sound()
	
	
	
	if proj.has_method("set_target"):
		proj.set_target(enemy.global_position)
	proj.damage = ranged_damage
	
	# mark it as an enemy‐fired shot so it won’t hit other enemies
	proj.fired_by_player = false
	

func play_attack_sound()->void:
	attack_sound.play()


func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)
