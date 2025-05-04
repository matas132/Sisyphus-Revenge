extends Node2D
const INFECTION = preload("res://entities/game_entities/Spells_&_Projectiles/plague/infection.tscn")
@onready var empower_end: Timer = $EmpowerEnd
@onready var effected_range: Area2D = $EffectedRange
@onready var effected_range_collision: CollisionShape2D = $EffectedRange/EffectedRangeCollision

@onready var plague_sfx: AudioMEventInstance2D = $PlagueSFX

@export var duration : float = 7.0

var affected_units : Array[Enemy]

func _ready() -> void:
	plague_sfx.play()
	empower_end.start(duration)
	effected_range_collision.set_deferred("disabled", false)
	await get_tree().create_timer(0.1,false).timeout
	
	
	for body in effected_range.get_overlapping_bodies():
		if body is Enemy:
			affect_unit(body)
			infect_enemy(body)

func infect_enemy(body: Enemy)->void:
	if body.debuffed == false:
		body.debuffed = true
		var burn = INFECTION.instantiate()
		#get_parent().add_child(burn)
		get_parent().call_deferred("add_child", burn)
		burn.followed_body = body

func _on_effected_range_body_entered(body: Node2D) -> void:
	if body is Enemy:
		affect_unit(body)
		infect_enemy(body)

func _on_effected_range_body_exited(body: Node2D) -> void:
	unaffect_unit(body)

func affect_unit(body: Node2D)->void:
	if body is Enemy:
		if !affected_units.has(body):
			body.speed *= 0.7
			affected_units.append(body)


func unaffect_unit(body: Node2D)->void:
	if body is Enemy:
		if affected_units.has(body):
			body.speed *= 1.3
			affected_units.erase(body)

func _on_empower_end_timeout() -> void:
	for body in affected_units:
		await get_tree().process_frame
		if body != null:
			unaffect_unit(body)
	
	
	remove()
	

func remove()->void:
	plague_sfx.stop()
	if plague_sfx.is_playing():
		await plague_sfx.done
	
	
	
	queue_free()
