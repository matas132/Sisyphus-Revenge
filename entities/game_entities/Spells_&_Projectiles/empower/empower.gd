extends Node2D
@onready var empower_vfx: Node2D = $EmpowerVFX

@onready var empower_end: Timer = $EmpowerEnd
@onready var effected_range: Area2D = $EffectedRange
@onready var effected_range_collision: CollisionShape2D = $EffectedRange/EffectedRangeCollision

@onready var empower_sfx: AudioMEventInstance2D = $EmpowerSFX

@export var duration : float = 5.0

var affected_units : Array[PlayerUnit]

func _ready() -> void:
	empower_sfx.play()
	empower_end.start(duration)
	effected_range_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	
	for body in effected_range.get_overlapping_bodies():
		affect_unit(body)
		
	



func _on_effected_range_body_entered(body: Node2D) -> void:
	affect_unit(body)
	empower_vfx.play()
	



func _on_effected_range_body_exited(body: Node2D) -> void:
	unaffect_unit(body)





func affect_unit(body: Node2D)->void:
	if body is PlayerUnit:
		if !affected_units.has(body):
			body.health += body.max_health * 0.5
			body.scale *= 1.3
			body.damage *= 1.5
			body.speed *= 1.5
			affected_units.append(body)


func unaffect_unit(body: Node2D)->void:
	if body is PlayerUnit:
		if affected_units.has(body):
			body.scale *= 0.7
			body.damage *= 0.5
			body.speed *= 0.5
			affected_units.erase(body)




func _on_empower_end_timeout() -> void:
	for body in affected_units:
		await get_tree().process_frame
		if body != null:
			unaffect_unit(body)
	
	
	remove()
	

func remove()->void:
	empower_sfx.stop()
	if empower_sfx.is_playing():
		await empower_sfx.done
	
	
	queue_free()
