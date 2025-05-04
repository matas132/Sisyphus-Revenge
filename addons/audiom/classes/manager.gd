@tool
class_name AudioMManager
extends Node

signal channel_count_changed

@export var channel_count: int = 64:
	set(value):
		channel_count = value
		channel_count_changed.emit()
@export var channel_count_2d: int = 0:
	set(value):
		channel_count_2d = value
		channel_count_changed.emit()
@export var event_tree: Node:
	set(value):
		event_tree = value
		update_configuration_warnings()
@export var global_parameters: Array[AudioMGlobalParameter]

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if not event_tree:
		warnings.append("Event Tree is missing, define it in the inspector")
	
	return warnings

func _ready() -> void:
	AudioM.add_manager(self)
