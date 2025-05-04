extends Node2D

const INFECTION = preload("res://entities/game_entities/Spells_&_Projectiles/plague/infection.tscn")
var direction : Vector2 = Vector2.ZERO

@onready var duration_timer: Timer = $Duration
@onready var burn_tick_timer: Timer = $BurnTick

@onready var spread_area: Area2D = $SpreadArea
@onready var spread_area_collision: CollisionShape2D = $SpreadArea/SpreadAreaCollision


@export var damage : float = 20.0

@export var duration : float = 10.0
@export var burn_tick : float = 0.5

@export var followed_body : Node2D

var max_travel_distance : float = 3000.0


func _ready() -> void:
	duration_timer.start(duration)
	burn_tick_timer.start(burn_tick)


func _physics_process(_delta: float) -> void:
	if followed_body !=null:
		global_position = followed_body.global_position
	else:
		remove()





func remove()->void:
	if followed_body != null:
		if followed_body is Enemy:
			followed_body.debuffed = false
	queue_free()
	


func _on_burn_tick_timeout() -> void:
	if followed_body !=null:
		if followed_body is Enemy:
			followed_body.take_damage(damage)
	else:
		remove()

func _on_duration_timeout() -> void:
	remove()


func _on_spread_area_body_entered(body: Node2D) -> void:
	if followed_body !=null:
		if body is Enemy:
			if body.debuffed == false:
				body.debuffed = true
				
				var burn = INFECTION.instantiate()
				
				get_parent().call_deferred("add_child", burn)
				burn.followed_body = body
			
			
