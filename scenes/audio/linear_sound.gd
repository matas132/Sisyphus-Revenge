class_name AudioStreamPlayerLinearVolume
extends AudioStreamPlayer

@export var loop_audio := false
var hidden := false
var default_volume :float
@export var loop_point : float = 0.0


var volume_level :float = 1.0:
	set(value):
		volume_level = value
		_linear_volume = default_volume * volume_level * volume_mult
var volume_mult :float = 1.0:
	set(value):
		volume_mult = value
		_linear_volume = default_volume * volume_level * volume_mult

var _linear_volume :float = 0.0:
	set(value):
		_linear_volume = value
		volume_db = linear_to_db(value)
	get:
		return db_to_linear(volume_db)

func _ready() -> void:
	default_volume = db_to_linear(volume_db)
	
	finished.connect(on_finished)

func on_finished() ->void:
	if loop_audio:
		play(loop_point)
	
