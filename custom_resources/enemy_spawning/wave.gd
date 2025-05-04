class_name Wave
extends Resource

## How long a wave will last before going into the next one
@export var wave_length :float
## How often an enemy spawns in seconds
@export var enemy_spawn_frequency : float = 1.8
@export var enemies : Array[EnemySpawn]

## Gets a random enemy based on its weight
func get_rand_enemy() -> String:
	var total_weight = 0
	for enemy in enemies:
		total_weight += enemy.weight
	var random_value = randi() % total_weight
	var cumulative_weight = 0

	for enemy in enemies:
		cumulative_weight += enemy.weight
		if random_value < cumulative_weight:
			return enemy.get_enemy_path()
	
	return enemies[0].get_enemy_path()
