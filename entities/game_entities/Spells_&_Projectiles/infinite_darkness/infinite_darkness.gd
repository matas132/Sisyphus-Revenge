extends Node2D
## places down sphere, it then moves direction opposite of mountain and deletes everything. 

var direction : Vector2 = Vector2.ZERO

@export var speed : float = 120.0
@export var damage : float = 150.0

@onready var damage_area_collision: CollisionShape2D = $DamageArea/DamageAreaCollision
@onready var infinite_darkness_sfx: AudioMEventInstance2D = $InfiniteDarknessSFX


var max_travel_distance : float = 2000.0

const olympus_location : Vector2 = Vector2(960.2,180.0)

func _ready() -> void:
	visible = false
	await get_tree().physics_frame
	await get_tree().process_frame
	
	global_position = olympus_location
	infinite_darkness_sfx.play()
	damage_area_collision.set_deferred("disabled", false)
	visible = true
	await get_tree().create_timer(0.1,false).timeout
	
	
	
	#direction = (get_tree().get_first_node_in_group("player_castle").global_position - global_position).normalized()
	#direction = direction * -1
	direction = (global_position.direction_to(get_viewport().get_mouse_position())).normalized()
	
func _physics_process(delta: float) -> void:
	position += delta * direction * speed
	
	
	if max_travel_distance < (get_tree().get_first_node_in_group("player_castle").global_position.distance_to(global_position)):
		remove()
		
		
		
	



func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)


func remove()->void:
	infinite_darkness_sfx.stop()
	if infinite_darkness_sfx.is_playing():
		await infinite_darkness_sfx.done
	
	queue_free()
