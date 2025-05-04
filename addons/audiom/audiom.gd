@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("AudioM", "res://addons/audiom/classes/instance.gd")
	add_custom_type(
			"AudioMManager", "AudioMManager",
			preload("classes/manager.gd"),
			preload("icons/Gizmo3DSamplePlayer.svg")
	)
	add_custom_type(
			"AudioMEvent", "AudioMEvent",
			preload("classes/event.gd"),
			preload("icons/AudioStreamWAV.svg")
	)
	add_custom_type(
			"AudioMEventInstance", "AudioMEventInstance",
			preload("classes/event_instance.gd"),
			preload("icons/AudioStreamPlayer.svg")
	)
	add_custom_type(
			"AudioMEventInstance2D", "AudioMEventInstance2D",
			preload("classes/event_instance_2d.gd"),
			preload("icons/AudioStreamPlayer2D.svg")
	)
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("AudioM")
	remove_custom_type("AudioMManager")
	remove_custom_type("AudioMEvent")
	remove_custom_type("AudioMEventInstance")
	pass
