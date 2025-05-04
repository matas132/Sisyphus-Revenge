@tool
class_name AudioMEvent
extends Node

@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "AudioMSound,AudioMSoundComposition") var sound: AudioMEventResource
@export var preview: bool = false:
	set(value):
		if value != preview:
			preview = value
			if preview:
				start_preview()
			else:
				stop_preview()

var preview_instance: AudioMEventInstance

func start_preview() -> void:
	if not Engine.is_editor_hint():
		return
	
	if preview_instance:
		preview_instance.queue_free()
	
	preview_instance = AudioMEventInstance.new()
	add_child(preview_instance)
	preview_instance.sound = sound
	preview_instance.update_sound()
	preview_instance.done.connect(_on_preview_instance_done)
	preview_instance.play()

func stop_preview() -> void:
	if preview_instance:
		preview_instance.stop()

func _on_preview_instance_done() -> void:
	preview_instance.queue_free()
