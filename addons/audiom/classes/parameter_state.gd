class_name AudioMParameterState
extends Node

signal change(name: String)

var state: Dictionary[String, float]
var parameters: Array[AudioMParameter]
var tweens: Dictionary[String, Tween]

func initialize(_parameters: Array) -> void:
	for _name in tweens:
		tweens[_name].stop()
		tweens.erase(_name)
	
	parameters.assign(_parameters)
	for param in parameters:
		if param.name in state:
			push_warning("Parameter name should be unique")
		state[param.name] = param.initial_value

func get_parameter_resource(_name: String) -> AudioMParameter:
	for param in parameters:
		if param.name == _name:
			return param
	return null

func get_parameter(_name: String) -> float:
	if not (_name in state) or _name == "":
		push_error("Cannot get undefined parameter")
		return 0
	return state[_name]

func get_parameter_by_index(param_index: int) -> float:
	if param_index >= parameters.size():
		return 0
	return get_parameter(parameters[param_index].name)

func set_parameter(_name: String, value: float, ignore_seek: bool = false) -> void:
	var param = get_parameter_resource(_name)
	
	if not param:
		push_error("Cannot set undefined parameter")
		return
	
	if not ignore_seek and param.seek_time > 0:
		if _name in tweens:
			tweens[_name].stop()
		
		tweens[_name] = get_tree().create_tween()
		tweens[_name].tween_method(
				_set_parameter_callable.bind(_name),
				state[_name],
				value,
				param.seek_time
		)
		tweens[_name].finished.connect(
				_on_seek_finished.bind(_name))
	else:
		state[_name] = value
		change.emit(_name)

func _set_parameter_callable(value: float, _name: String) -> void:
	set_parameter(_name, value, true)

func _on_seek_finished(_name: String) -> void:
	tweens.erase(_name)
