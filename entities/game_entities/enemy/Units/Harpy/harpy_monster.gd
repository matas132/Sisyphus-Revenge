class_name Harpy
extends Enemy

@export var preferred_distance : float = 60.0
@onready var attack_sound: AudioMEventInstance2D = $AttackSound
@onready var swing_sound: AudioMEventInstance2D = $SwingSound
const DAMAGED = preload("res://assets/Entities/Enemy units/half_health/harpy_damaged.png")
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
		if body.is_in_group("player_castle"):
			var d = global_position.distance_to(body.global_position)
			if d < best_dist:
				best_dist = d
				best_unit = body
	return best_unit

func check_detected_bodies() -> void:
	direction = castle_direction

func play_attack_sound()->void:
	attack_sound.play()
	

func play_attack_wind_up()->void:
	swing_sound.play()

func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)
