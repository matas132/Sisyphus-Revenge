class_name SummonerUnit
extends PlayerUnit

const PETRIFIED = preload("res://assets/Entities/player units cards/petrified/GameJam-ControlledChaos-Unit-Ally-Summoner-Petrified-Small.png")

const DAMAGED = preload("res://assets/Entities/player units cards/half_health/GameJam-ControlledChaos-Unit-Ally-Summoner-Damaged-Small.png")

@export var minion_scene: PackedScene
@export var spawn_interval: float = 3.0  # Time in seconds between spawns
@export var max_minions: int = 6         # Maximum number of minions allowed
@export var preferred_distance : float = 150.0
var minions: Array = []

@onready var spawn_timer: Timer = $SpawnTimer




func _ready() -> void:
	
	# Set up the spawn timer
	spawn_timer.wait_time = spawn_interval
	
	
	add_to_group("free_player_units")
	# Initialize the base PlayerUnit
	init()

# override the generic attack
func attack_target(_delta):
	var to_enemy = target_enemy.global_position - global_position
	var dist = to_enemy.length()
	if dist < preferred_distance:
		direction = -to_enemy.normalized()
	elif dist > preferred_distance * 1.2:
		direction = to_enemy.normalized()
	else:
		direction = Vector2.ZERO

func _on_spawn_timer_timeout() -> void:
	# Clean up any minions that have been freed
	minions = minions.filter(func(m): return is_instance_valid(m))
	
	if minions.size() >= max_minions:
		return
	
	# Spawn a new minion
	var minion = minion_scene.instantiate()
	
	var spawn_radius = 80.0  # Adjust this value as needed
	var angle = randf() * TAU  # TAU is 2π, representing a full circle
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	minion.global_position = global_position + offset
	
	get_parent().add_child(minion)
	minions.append(minion)



func on_stunned()->void:
	sprite.sprite_2d.texture = PETRIFIED
	sprite.animation_player.stop()

func on_unstunned()->void:
	sprite.default_texture()

func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)
