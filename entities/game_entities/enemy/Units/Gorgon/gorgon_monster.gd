class_name Gorgon
extends Enemy
@onready var attack_sprite: AudioMEventInstance2D = $AttackSprite

@export var aoe_radius : float = 100.0
@export var stun_duration : float = 3.0
@export var preferred_distance : float = 60.0


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
		elif dist > preferred_distance:
			direction = to_target.normalized()
		else:
			direction = Vector2.ZERO
	
	
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

func _on_damage_rate_timeout() -> void:
	var bodies = hurt_box.get_overlapping_bodies()
	for body in bodies:
		if body is PlayerUnit:
			sprite.attack()
			await get_tree().create_timer(animation_attack_delay,false).timeout
			play_attack_sound()
			body.take_damage(damage)
			body.apply_stun(stun_duration)
			
		elif body.is_in_group("player_castle"):
			sprite.attack()
			await get_tree().create_timer(animation_attack_delay,false).timeout
			play_attack_sound()
			body.take_damage(damage)
		
		#elif body is Enemy && body != self:
			#if body.has_method("apply_stun"):
				#body.apply_stun(stun_duration)

func play_attack_sound()->void:
	attack_sprite.play()

#func on_half_health()->void:
#	sprite.set_new_sprite_texture(DAMAGED)
