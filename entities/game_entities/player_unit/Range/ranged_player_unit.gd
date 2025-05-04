class_name RangedPlayerUnit
extends PlayerUnit

const PETRIFIED = preload("res://assets/Entities/player units cards/petrified/GameJam-ControlledChaos-Unit-Ally-Toxotes-Petrified-Small.png")

const DAMAGED = preload("res://assets/Entities/player units cards/half_health/GameJam-ControlledChaos-Unit-Ally-Toxotes-Damaged-Small.png")

@onready var attack_sound: AudioMEventInstance2D = $AttackSound
@onready var swing_sound: AudioMEventInstance2D = $SwingSound

@export var preferred_distance : float = 150.0
@export var projectile_scene : PackedScene
@export var ranged_damage : float = 3.0
 #SFX/Unit/AttackBowShoot
# Ranged units move slower
func _ready() -> void:
	
	
	add_to_group("free_player_units")
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
	
	
	
	# fire when timer ready
	if damage_rate_timer.is_stopped():
		damage_rate_timer.start(damage_rate)
		var p = projectile_scene.instantiate()
		get_parent().call_deferred("add_child",p)
		await get_tree().process_frame
		p.fired_by_player = true
		p.global_position = global_position
		#p.look_at(target_enemy.global_position)
		if p.has_method("set_target"):
			p.set_target(target_enemy.global_position)
		p.damage = ranged_damage
		#get_tree().current_scene.add_child(p)
		
		play_attack_sound() 
		play_attack_anim(target_enemy)

func play_attack_sound()->void:
	attack_sound.play()



func on_stunned()->void:
	sprite.sprite_2d.texture = PETRIFIED
	sprite.animation_player.stop()

func on_unstunned()->void:
	sprite.default_texture()

func on_half_health()->void:
	sprite.set_new_sprite_texture(DAMAGED)


func play_attack_wind_up()->void:
	swing_sound.play()
