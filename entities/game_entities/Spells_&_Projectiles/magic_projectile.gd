extends Area2D

@export var speed : float = 200.0
@export var damage : float = 3.0
var direction : Vector2
var fired_by_player: bool = false  # Set to true if fired by a PlayerUnit

@onready var sprite : Sprite2D = $Sprite2D
const player_arrow = preload("res://assets/Entities/projectile/GameJam-ControlledChaos-Unit-Ally-Arrow.png")
const enemy_arrow = preload("res://assets/Entities/projectile/GameJam-ControlledChaos-Unit-Enemy-Arrow.png")
@onready var attack_sound: AudioMEventInstance2D = $AttackSound
@onready var collider: CollisionShape2D = $CollisionShape2D

var setup_done := false

func set_target(target_pos: Vector2):
	direction = (target_pos - global_position).normalized()
	#print(str(direction))
	#print("default rot " + str(sprite.rotation_degrees))
	sprite.look_at(target_pos)
	sprite.rotation_degrees += 90
	#print("look at rot " + str(sprite.rotation_degrees))

func _ready():
	if direction != Vector2.ZERO:
		#sprite.rotation = direction.angle()
		sprite.texture = player_arrow if fired_by_player else enemy_arrow
		setup_done = true

func _physics_process(delta: float) -> void:
	if not setup_done and direction != Vector2.ZERO:
		#sprite.rotation = direction.angle()
		sprite.texture = player_arrow if fired_by_player else enemy_arrow
		setup_done = true
	
	position += direction * speed * delta
	
	if global_position.distance_to(Vector2(960,540)) > 3000:
		remove()


func remove()->void:
	#await get_tree().process_frame
	collider.set_deferred("disabled",true)
	sprite.visible = false
	speed = 0.0
	if attack_sound.is_playing():
		await attack_sound.done
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if fired_by_player:
		# If fired by the player, only damage Enemy objects
		if body is Enemy && speed != 0.0:
			body.take_damage(damage)
			attack_sound.play()
			remove()
	
	else:
		if body is PlayerUnit or body.is_in_group("player_castle"):
			body.take_damage(damage)
			if body is PlayerUnit && speed != 0.0:
				body._hit_by_projectile(global_position)
				attack_sound.play()
			remove()
	
