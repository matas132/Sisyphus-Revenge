@tool
class_name AudioMSoundParameter
extends AudioMParameter

@export var name: String
@export var global: bool = false:
	set(value):
		global = value
		notify_property_list_changed()
@export_range(0, 1) var initial_value: float = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var seek_time: float = 0
@export var modulations: Array[AudioMSoundModulation]

func _validate_property(property: Dictionary) -> void:
	if property.name == "initial_value" or property.name == "seek_time":
		property.usage = (
				PROPERTY_USAGE_DEFAULT if not global
				else PROPERTY_USAGE_NO_EDITOR
		)
