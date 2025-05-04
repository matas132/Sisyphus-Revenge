extends Node2D
#const PLAYER_UNIT = preload("res://entities/game_entities/player_unit/player_unit.tscn")
#const PLAYER_UNIT = preload("res://entities/game_entities/player_unit/hoplite/hoplite.tscn")
const PLAYER_UNIT = preload("res://entities/game_entities/player_unit/hoplite/hoplite_undead.tscn")
#const MINION_UNIT = preload("res://entities/game_entities/player_unit/Summoner/Minions/minion_unit.tscn")
@onready var durationTimer: Timer = $Duration

@export var duration : float = 10

@export var summon_amount : int = 6
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var summon_cooldown : float = 1.3

const GAME_JAM_CONTROLLED_CHAOS_UNIT_ALLY_ZOMBIE = preload("res://assets/Entities/player units cards/GameJam-ControlledChaos-Unit-Ally-Zombie.png")
@onready var necromancy_sfx: AudioMEventInstance2D = $NecromancySFX

func _ready() -> void:
	necromancy_sfx.play()
	
	durationTimer.start(duration)
	
	for i in summon_amount:
		
		var summon : PlayerUnit = PLAYER_UNIT.instantiate()
		
		await get_tree().create_timer(summon_cooldown).timeout
		
		#get_parent().add_child(summon)
		get_parent().call_deferred("add_child",summon)
		#await get_tree().process_frame
		
		var rand_pos : Vector2 = Vector2(randf_range(-100,100), randf_range(-100,100))
		
		summon.global_position = global_position + rand_pos
		await get_tree().process_frame
		summon.init()
		#summon.take_damage(110)
		#summon.sprite.texture = GAME_JAM_CONTROLLED_CHAOS_UNIT_ALLY_ZOMBIE
		
		#await get_tree().process_frame
		#summon.set_dir_to_castle()
		
		
		
	
	


func _on_duration_timeout() -> void:
	necromancy_sfx.stop()
	if necromancy_sfx.is_playing():
		await necromancy_sfx.done
	
	
	
	remove()
	

func remove()->void:
	queue_free()
