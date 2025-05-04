class_name MinionUnit
extends PlayerUnit

const PETRIFIED = preload("res://assets/Entities/player units cards/petrified/GameJam-ControlledChaos-Unit-Ally-Minion-Petrified-Small.png")

const DAMAGED = preload("res://assets/Entities/player units cards/half_health/GameJam-ControlledChaos-Unit-Ally-Minion-Damaged-Small.png")
@onready var attack_sound: AudioMEventInstance2D = $AttackSound
@onready var swing_sound: AudioMEventInstance2D = $SwingSound

@export var preferred_distance : float = 60.0

func _ready() -> void:
	
	add_to_group("free_player_units")
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



func on_stunned()->void:
	sprite.sprite_2d.texture = PETRIFIED
	sprite.animation_player.stop()

func on_unstunned()->void:
	sprite.default_texture()

func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)

func play_attack_wind_up()->void:
	swing_sound.play()

func play_attack_sound()->void:
	attack_sound.play()
