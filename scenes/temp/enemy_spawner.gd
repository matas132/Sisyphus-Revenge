extends Node
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var enemy_spawn_path: PathFollow2D = $"../EnemySpawnPath/PathFollow2D"
@onready var enemy_spawn_path_2d: Path2D = $"../EnemySpawnPath"

@onready var entities: Node = $"../Entities"
@onready var wave_timer: Timer = $WaveTimer

const ENEMY = preload("res://entities/game_entities/enemy/enemy.tscn")

@export var waves : Array[Wave]

var current_wave : int = -1

signal new_wave(wave_number : int)

func _ready() -> void:
	start_wave()

func start_wave()->void:
	current_wave+=1
	new_wave.emit(current_wave)
	#print( "current wave " +str(current_wave))
	
	if current_wave == waves.size():
		on_waves_ended()
		return
	
	wave_timer.start(waves[current_wave].wave_length)
	enemy_spawn_timer.start(waves[current_wave].enemy_spawn_frequency)
	

func _on_enemy_spawn_timer_timeout() -> void:
	if entities.get_child_count() > 200:
		return
	
	var rand_prog = randf_range(0.0,1.0)
	enemy_spawn_path.progress_ratio = rand_prog
	
	var enemy_path : String = waves[current_wave].get_rand_enemy()
	
	var enemy : Enemy = load(enemy_path).instantiate()
	entities.add_child(enemy)
	enemy.global_position = enemy_spawn_path.global_position
	enemy.init()

func on_waves_ended()->void:
	#print("waves ended")
	enemy_spawn_timer.stop()
	wave_timer.stop()
	#await get_tree().create_timer(5,false).timeout
	#temp_game.on_game_completed()
	pass


func _on_wave_timer_timeout() -> void:
	
	start_wave()
	
	
	
