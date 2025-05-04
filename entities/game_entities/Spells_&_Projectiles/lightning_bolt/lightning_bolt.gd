class_name LightningBolt
extends Node2D
## Click on an enemy and it smites them with lightning, 
## then that lightning spreads to a few other surrounding enemies.

const LIGHTNING = preload("res://entities/game_entities/Spells_&_Projectiles/lightning_bolt/lightning.tscn")

@onready var initial_lightning_strike_collision: CollisionShape2D = $InitialLightningStrike/InitialLightningStrikeCollision
@onready var initial_lightning_strike: Area2D = $InitialLightningStrike

@onready var lightning_bolt_sound: AudioMEventInstance2D = $LightningBoltSound


@onready var lightning_strike_spread: Area2D = $LightningStrikeSpread
@onready var lightning_strike_spread_collision: CollisionShape2D = $LightningStrikeSpread/LightningStrikeSpreadCollision

@export var initial_strike_damage : float = 100.0
@export var lightning_target_amount : int = 13
@export var lightning_spread_damage : float = 80.0

@onready var lightning_vfx: LightningVFX = $LightningVFX



func _ready() -> void:
	lightning_vfx.appear()
	lightning_bolt_sound.play()
	
	initial_lightning_strike_collision.set_deferred("disabled", false)
	lightning_strike_spread_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.37,false).timeout
	
	
	
	var striked_enemy : bool = false
	for body in initial_lightning_strike.get_overlapping_bodies():
		if body is Enemy:
			striked_enemy = true
			body.take_damage(initial_strike_damage)
	
	if !striked_enemy:
		remove() # didn't hit any enemies, so disappear
		return
	
	
	spread_lightning()
	
	
	
	
	


func spread_lightning()->void:
	
	if lightning_strike_spread.get_overlapping_bodies().size() <=0:
		return
	var enemies : Array[Enemy]
	for body in lightning_strike_spread.get_overlapping_bodies():
		if body is Enemy:
			enemies.append(body)
	
	
	
	
	var lightning = LIGHTNING.instantiate()
	var targeted : int = 0
	
	lightning.add_point(global_position)
	
	for enemy in enemies:
		if enemies.size() != 0 && targeted < lightning_target_amount:
			var rand_num := randi_range(0, enemies.size() -1)
			enemies[rand_num].take_damage(lightning_spread_damage)
			
			lightning.add_point(enemies[rand_num].global_position)
			
			enemies.erase(enemies[rand_num])
			targeted+=1
			
			
		
	
	add_child(lightning)
	#lightning.global_position = global_position
	
	
	await get_tree().create_timer(1.7).timeout
	remove()
	





func remove()->void:
	if lightning_bolt_sound.is_playing():
		await lightning_bolt_sound.done
	
	if lightning_vfx.is_playing():
		await lightning_vfx.done
	
	queue_free()
