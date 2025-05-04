@tool
class_name AudioMSoundModulation
extends Resource

enum Property {VOLUME, PITCH, COMPOSITION_VOLUME, COMPOSITION_PITCH}
@export var property: Property = Property.VOLUME:
	set(value):
		property = value
		notify_property_list_changed()
@export var layer_index: int = 0
@export var amount: float = 0

func _validate_property(_property: Dictionary) -> void:
	if _property.name == "layer_index":
		_property.usage = PROPERTY_USAGE_DEFAULT if (
				property == Property.VOLUME \
				or property == Property.PITCH
		) else PROPERTY_USAGE_NO_EDITOR
	if _property.name == "amount":
		if (
				property == Property.VOLUME \
				or property == Property.COMPOSITION_VOLUME
		):
			_property.hint = PROPERTY_HINT_RANGE
			_property.hint_string = "-2,2,0.01,or_greater,or_less"
		elif (
				property == Property.PITCH \
				or property == Property.COMPOSITION_PITCH
		):
			_property.hint = PROPERTY_HINT_RANGE
			_property.hint_string = "-60,60,0.01,suffix:st"
		else:
			_property.hint = PROPERTY_HINT_NONE
			_property.hint_string = ""
