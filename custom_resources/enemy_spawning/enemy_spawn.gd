class_name EnemySpawn
extends Resource

enum EnemyType {
	greek_soldier,
	cyclops,
	harpy,
	greek_cavalry,
	gorgon,
	greek_archer,
	chimera,
	
}

var enemy_paths : Dictionary[EnemyType, String] = {
	EnemyType.greek_soldier: "res://entities/game_entities/enemy/Units/Soldier/greek_soldier.tscn",
	EnemyType.cyclops: "res://entities/game_entities/enemy/Units/Cyclops/cyclops_monster.tscn",
	EnemyType.harpy: "res://entities/game_entities/enemy/Units/Harpy/harpy_monster.tscn",
	EnemyType.greek_cavalry: "res://entities/game_entities/enemy/Units/Cavalry/greek_cavalry.tscn",
	EnemyType.gorgon: "res://entities/game_entities/enemy/Units/Gorgon/gorgon_monster.tscn",
	EnemyType.greek_archer: "res://entities/game_entities/enemy/Units/Archer/greek_archer.tscn",
	EnemyType.chimera: "res://entities/game_entities/enemy/Units/chimera/chimera.tscn",
}

@export var enemy : EnemyType

@export var weight : int = 1

func get_enemy_path()->String:
	return enemy_paths[enemy]
