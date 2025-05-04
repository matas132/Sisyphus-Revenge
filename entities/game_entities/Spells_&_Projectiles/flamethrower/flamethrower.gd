extends Node2D
const FLAME = preload("res://entities/game_entities/Spells_&_Projectiles/flamethrower/flame.tscn")
@onready var dps_timer: Timer = $DPStimer
@onready var duration_timer: Timer = $DurationTimer

@export var damage_interval : float = 0.3
@export var duration : float = 5.0
@export var flame_damage : float = 30.0

func _ready() -> void:
	dps_timer.start(damage_interval)
	duration_timer.start(duration)

## dp stimer
func _on_dp_stimer_timeout() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		var flame = FLAME.instantiate()
		
		
		get_parent().add_child(flame)
		flame.global_position = get_viewport().get_mouse_position()
		flame.damage = flame_damage
		#await get_tree().process_frame
		
		
		
		
		



func _on_duration_timer_timeout() -> void:
	remove()


func remove()->void:
	queue_free()
