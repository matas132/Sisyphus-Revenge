class_name BossController
extends Node2D

enum Phase { LEFT, HEAD, RIGHT }

# Configurable timings
@export var phase_interval: float = 1.0   # delay between end→start

signal boss_defeated

var phases = [Phase.LEFT, Phase.HEAD, Phase.RIGHT]
var current_idx = 0
var parts = {}    # Phase → BossPart

func _ready():
	# Gather parts by type
	parts[Phase.LEFT]  = $LeftHand
	parts[Phase.HEAD]  = $Head
	parts[Phase.RIGHT] = $RightHand
	
	# Connect signals
	for phase in phases:
		var part = parts[phase]
		part.connect("attack_finished", Callable(self, "_on_part_finished").bind(phase))
		part.connect("part_dead",      Callable(self, "_on_part_dead"))
	
	# Start the cycle
	_combat_loop()

func _combat_loop() -> void:
	while phases.size() > 0:
		var phase = phases[current_idx]
		var part  = parts.get(phase)
		await get_tree().process_frame
		if part and part.health > 0:
			part.start_attack()
			await part.attack_finished
			await get_tree().create_timer(phase_interval).timeout
		else :
			pass
		
		
		await get_tree().process_frame
		if phases.size() == 0:
			return
		
		current_idx = (current_idx + 1) % phases.size()

func _on_part_finished(_finished_phase):
	#print("finished:", finished_phase, "current_idx:", current_idx)
	pass

func _on_part_dead(dead_phase):
	phases.erase(dead_phase)
	parts.erase(dead_phase)
	
	if phases.is_empty():
		boss_defeated.emit()
