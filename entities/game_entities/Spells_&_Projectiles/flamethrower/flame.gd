extends Node2D
## the thing that appears when you press mouse to use flamethrower
const BURN = preload("res://entities/game_entities/Spells_&_Projectiles/flamethrower/burn.tscn")
var direction : Vector2 = Vector2.ZERO

@export var speed : float = 120.0
@export var damage : float = 10.0

@onready var damage_area: Area2D = $DamageArea
@onready var damage_area_collision: CollisionShape2D = $DamageArea/DamageAreaCollision

@onready var flame_vfx: Node2D = $FlameVFX
@onready var flame_sfx: AudioMEventInstance2D = $FlameSFX

var max_travel_distance : float = 3000.0

func _ready() -> void:
	flame_sfx.play()
	damage_area_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	for body in damage_area.get_overlapping_bodies():
		if body is Enemy:
			body.take_damage(damage)
			
			if body.debuffed == false:
				body.debuffed = true
				var burn = BURN.instantiate()
				#get_parent().add_child(burn)
				get_parent().call_deferred("add_child", burn)
				burn.followed_body = body
	
	remove()
	







func remove()->void:
	
	await get_tree().create_timer(4,false).timeout
	flame_sfx.stop()
	
	if flame_sfx.is_playing():
		await flame_sfx.done
	
	
	queue_free()



func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
			body.take_damage(damage)
			if body.debuffed == false:
				body.debuffed = true
				var burn = BURN.instantiate()
				get_parent().call_deferred("add_child", burn)
				burn.followed_body = body
