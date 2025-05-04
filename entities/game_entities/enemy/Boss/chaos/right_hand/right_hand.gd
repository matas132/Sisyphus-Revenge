class_name RightHand
extends BossPart

@export var summon_interval: float = 1.0
@export var summons_per_attack: int = 10
@export var minion_scene: PackedScene
@onready var raise_dead: AudioMEventInstance2D = $RaiseDead

func _ready() -> void:
	part_type  = PartType.RIGHT_HAND
	spawn_area = get_parent().get_node("RightArea")
	windup_time   = 1.0
	
	init()



func do_raise_dead() -> void:
	#if has_node("AnimationPlayer"):
	#	$AnimationPlayer.play("summon_start")
	sprite.attack()
	raise_dead.play()
	await get_tree().create_timer(0.4).timeout
	
	for i in range(summons_per_attack):
		var m = minion_scene.instantiate()
		var spawn_radius = 80.0  # Adjust this value as needed
		var angle = randf() * TAU  # TAU is 2π, representing a full circle
		var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
		m.global_position = global_position + offset
		
		get_parent().add_child(m)
		await get_tree().create_timer(summon_interval).timeout
	
	raise_dead.stop()

	#if has_node("AnimationPlayer"):
	#	$AnimationPlayer.play("summon_end")
	sprite.idle()
	
	
