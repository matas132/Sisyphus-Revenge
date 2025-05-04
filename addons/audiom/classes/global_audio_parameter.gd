class_name AudioMGlobalParameter
extends AudioMParameter

@export var name: String
@export_range(0, 1) var initial_value: float = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var seek_time: float = 0
