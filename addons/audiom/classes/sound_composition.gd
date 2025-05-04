@tool
class_name AudioMSoundComposition
extends AudioMEventResource

signal volume_changed
signal pitch_changed

@export var layers: Array[AudioMSound]
@export_range(0, 1.2, 0.01, "or_greater") var volume: float = 1:
	set(value):
		volume = value
		volume_changed.emit()
## Determines how volume modulations will mix together
@export var volume_mod_mixing: AudioMSound.Mixing = AudioMSound.Mixing.MAX
@export_range(-60, 60, 0.01, "suffix:st") var pitch: float = 0:
	set(value):
		pitch = value
		pitch_changed.emit()
## Determines how pitch modulations will mix together
@export var pitch_mod_mixing: AudioMSound.Mixing = AudioMSound.Mixing.ADD

@export_group("Repeater")
@export var repeat: bool = false:
	set(value):
		repeat = value
		notify_property_list_changed()
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var repeat_interval: float = 1
@export var interrupt_voices_on_stop: bool = false

@export_group("Overrides")
@export var override_enter_time: bool = false:
	set(value):
		override_enter_time = value
		notify_property_list_changed()
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var enter_time: float = 0
@export var override_leave_time: bool = false:
	set(value):
		override_leave_time = value
		notify_property_list_changed()
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var leave_time: float = 0.2

@export_group("Parameters")
@export var parameters: Array[AudioMSoundParameter]
@export var affect_active_voices: bool = true

func _validate_property(property: Dictionary) -> void:
	if property.name == 'repeat_interval':
		property.usage = PROPERTY_USAGE_DEFAULT if repeat else PROPERTY_USAGE_NO_EDITOR
	if property.name == 'enter_time':
		property.usage = PROPERTY_USAGE_DEFAULT if override_enter_time else PROPERTY_USAGE_NO_EDITOR
	if property.name == 'leave_time':
		property.usage = PROPERTY_USAGE_DEFAULT if override_leave_time else PROPERTY_USAGE_NO_EDITOR
