extends Node
const BOSS_CONTROLLER = preload("res://entities/game_entities/enemy/Boss/boss_controller.tscn")
const BLACK_FADE = preload("res://entities/game_entities/visuals/black_fade.tscn")
@onready var hand: CardHand = $"../GameUI/Hand"

@onready var entities: Node2D = $"../Entities"

@onready var enemy_spawner: Node = $"../EnemySpawner"
@onready var card_giver: Node = $"../CardGiver"
@onready var label: Label = $Label

@onready var temp_game: Node2D = $".."

signal boss_wave


func _ready() -> void:
	enemy_spawner.new_wave.connect(on_new_wave)


func on_new_wave(wave : int)->void:
	label.text = "current wave: " + str(wave)
	
	match wave:
		#1: # NOTE TEmp
			#var boss_fade = BLACK_FADE.instantiate()
			#entities.add_child(boss_fade)
			#await get_tree().create_timer(0.8).timeout
			
			#card_giver.card_gain_interval = 0.5
			#var boss = BOSS_CONTROLLER.instantiate()
			#entities.add_child(boss)
			#boss.boss_defeated.connect(func():temp_game.on_game_completed() )
		#2:
		#	card_giver.card_gain_interval = 4.5
		4:
			hand.add_card(load("res://custom_resources/card/cards/spell_cards/black_hole.tres"))
			card_giver.card_gain_interval = 4.8
		7:
			card_giver.card_gain_interval = 4.5
		9:
			card_giver.card_gain_interval = 4
		11:
			card_giver.card_gain_interval = 3.5
		12:
			card_giver.card_gain_interval = 3
			
			var boss_fade = BLACK_FADE.instantiate()
			entities.add_child(boss_fade)
			await get_tree().create_timer(0.8).timeout
			
			var boss = BOSS_CONTROLLER.instantiate()
			entities.add_child(boss)
			boss.boss_defeated.connect(func():temp_game.on_game_completed() )
			
			boss_wave.emit()
		13:
			card_giver.card_gain_interval = 2.7
