class_name AudioMEventInstance2D
extends Node2D

signal stopping
signal stopped
signal done

@export var event_path: String:
	set(value):
		if value != event_path:
			event_path = value
			if instance:
				instance.event_path = event_path

var instance: AudioMEventInstance

var is_stopping: bool:
	get:
		return instance.is_stopping if instance else false

func _ready() -> void:
	instance = AudioMEventInstance.new()
	add_child(instance)
	instance.event_path = event_path
	instance.position_type = AudioMChannel.PositionType.POSTIONAL_2D
	instance.stopping.connect(_on_instance_stopping)
	instance.stopped.connect(_on_instance_stopped)
	instance.done.connect(_on_instance_done)
	instance._playback_ref_created.connect(_on_playback_ref_created)

func get_parameter(_name: String) -> float:
	return instance.get_parameter(_name)

func set_parameter(_name: String, value: float, ignore_seek: bool = false) -> void:
	instance.set_parameter(_name, value, ignore_seek)

func play(
		offset: float = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> void:
	instance.play(offset, default_priority)

func stop() -> void:
	instance.stop()

func force_stop() -> void:
	instance.force_stop()

func is_playing() -> bool:
	return instance.is_playing()

func is_repeating() -> bool:
	return instance.is_repeating()

func get_playback_position(active_layer_index: int = 0) -> float:
	return instance.get_playback_position(active_layer_index)

func get_layer_delay(active_layer_index: int = 1) -> float:
	return instance.get_layer_delay(active_layer_index)

func _on_instance_stopping() -> void:
	stopping.emit()

func _on_instance_stopped() -> void:
	stopped.emit()

func _on_instance_done() -> void:
	done.emit()

func _on_playback_ref_created(playback_ref: AudioMPlaybackReference) -> void:
	var location = AudioMSoundLocation2D.new(playback_ref.sound_handler.player.player)
	add_child(location)
	playback_ref.done.connect(_on_playback_ref_done.bind(location))

func _on_playback_ref_done(location: AudioMSoundLocation2D) -> void:
	location.release()
	location.queue_free()
