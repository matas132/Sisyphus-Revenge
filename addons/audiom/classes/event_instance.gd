class_name AudioMEventInstance
extends Node

signal stopping
signal stopped
signal done

signal _playback_ref_created(playback_ref: AudioMPlaybackReference)

@export var event_path: String:
	set(value):
		if value != event_path:
			event_path = value
			if is_node_ready():
				update_sound()

var position_type: AudioMChannel.PositionType
var sound: AudioMEventResource
var last_sound: AudioMEventResource
var playback_refs: Array[AudioMPlaybackReference]
var playback_refs_map: Dictionary[int, Array]
var param_state: AudioMParameterState
enum ModulationSource {LOCAL_PARAMETER, GLOBAL_PARAMETER}
var mod_list: Array[Dictionary]
var local_param_count: int = 0
var global_param_count: int = 0
var composition_volume_mods: Array[float] = []
var composition_pitch_mods: Array[float] = []
var layer_volume_mod_map: Array[Array] = []
var layer_pitch_mod_map: Array[Array] = []
var volume_fade_in: float = 1:
	set(value):
		volume_fade_in = value
		update_fade_in_levels()
var volume_fade_out: float = 1:
	set(value):
		volume_fade_out = value
		update_fade_out_levels()

var is_stopping = false

var fade_in_tween: Tween
var fade_out_tween: Tween

var repeat_time: float
var repeat: bool

func _enter_tree() -> void:
	param_state = AudioMParameterState.new()
	add_child(param_state)

func _exit_tree() -> void:
	stop()

func _ready() -> void:
	param_state.change.connect(_on_local_param_change)

	if not sound:
		update_sound()

func _process(delta: float) -> void:
	if is_repeating():
		repeat_time += delta
		if repeat_time >= max(sound.repeat_interval, 0.01):
			play_composition(sound)
			repeat_time = 0

func update_sound() -> void:
	if sound and last_sound == sound:
		return
	
	if is_playing():
		force_stop()
	
	last_sound = sound
	
	if sound and sound.volume_changed.is_connected(_on_sound_volume_changed):
		sound.volume_changed.disconnect(_on_sound_volume_changed)
	if sound and sound.pitch_changed.is_connected(_on_sound_pitch_changed):
		sound.pitch_changed.disconnect(_on_sound_pitch_changed)

	if not event_path == "":
		sound = AudioM.get_event_resource(event_path)
	
	if not (sound is AudioMSoundComposition):
		return
	
	sound.volume_changed.connect(_on_sound_volume_changed)
	sound.pitch_changed.connect(_on_sound_pitch_changed)
	
	if has_global_parameters():
		if not AudioM.param_state.change.is_connected(_on_global_param_change):
			AudioM.param_state.change.connect(_on_global_param_change)
	else:
		if AudioM.param_state.change.is_connected(_on_global_param_change):
			AudioM.param_state.change.disconnect(_on_global_param_change)
	
	param_state.initialize(sound.parameters)
	
	update_mod_maps()
	apply_mods()

func update_mod_maps() -> void:
	if sound is not AudioMSoundComposition:
		return
	
	mod_list = []
	local_param_count = 0
	global_param_count = 0
	composition_volume_mods = []
	composition_pitch_mods = []
	layer_volume_mod_map = []
	layer_pitch_mod_map = []

	for param_index in sound.parameters.size():
		var param: AudioMSoundParameter = sound.parameters[param_index]
		
		var mod_info: Dictionary[String, int]
		mod_info.group = (
				ModulationSource.GLOBAL_PARAMETER if param.global
				else ModulationSource.LOCAL_PARAMETER
		)
		
		match mod_info.group:
			ModulationSource.LOCAL_PARAMETER:
				mod_info.group_index = local_param_count
				local_param_count += 1
			ModulationSource.GLOBAL_PARAMETER:
				mod_info.group_index = global_param_count
				global_param_count += 1
		
		mod_list.append(mod_info)
		
		for modulation: AudioMSoundModulation in param.modulations:
			var mod_map: Array[Array]
			var mod_amounts: Array[float]
			match modulation.property:
				AudioMSoundModulation.Property.VOLUME:
					mod_map = layer_volume_mod_map
				AudioMSoundModulation.Property.PITCH:
					mod_map = layer_pitch_mod_map
				AudioMSoundModulation.Property.COMPOSITION_VOLUME:
					mod_amounts = composition_volume_mods
				AudioMSoundModulation.Property.COMPOSITION_PITCH:
					mod_amounts = composition_pitch_mods
			
			if modulation.property == AudioMSoundModulation.Property.VOLUME \
					or modulation.property == AudioMSoundModulation.Property.PITCH:
				if modulation.layer_index >= sound.layers.size():
					continue
				if mod_map.size() == 0:
					for layer_index in sound.layers.size():
						mod_map.append([] as Array[float])
				mod_amounts = mod_map[modulation.layer_index]
			
			if mod_amounts.size() == 0:
				for _param_index in sound.parameters.size():
					mod_amounts.append(0)
			mod_amounts[param_index] += modulation.amount

func apply_mods() -> void:
	if not (sound is AudioMSoundComposition):
		return
	for layer_index in sound.layers.size():
		if not (layer_index in playback_refs_map):
			continue
		apply_layer_mods(layer_index)
	update_mix()

func apply_layer_mods(layer_index: int) -> void:
	if not (sound is AudioMSoundComposition):
		return
	apply_layer_mod(layer_index, AudioMSoundModulation.Property.VOLUME)
	apply_layer_mod(layer_index, AudioMSoundModulation.Property.PITCH)

func apply_layer_mod(layer_index, property: AudioMSoundModulation.Property) -> void:
	if not (layer_index in playback_refs_map):
		return
	
	var mod_map: Array[Array]
	var mixing: AudioMSound.Mixing
	var amount: float = 0
	
	match property:
		AudioMSoundModulation.Property.VOLUME:
			mod_map = layer_volume_mod_map
			mixing = sound.layers[layer_index].volume_mod_mixing
		AudioMSoundModulation.Property.PITCH:
			mod_map = layer_pitch_mod_map
			mixing = sound.layers[layer_index].pitch_mod_mixing
	
	if layer_index < mod_map.size():
		amount = get_mod_total_amount(mod_map[layer_index], mixing)
	
	for ref: AudioMPlaybackReference in playback_refs_map[layer_index]:
		if not sound.affect_active_voices and ref.is_playing:
			continue
		match property:
			AudioMSoundModulation.Property.VOLUME:
				ref.sound_handler.volume_mod = amount
			AudioMSoundModulation.Property.PITCH:
				ref.sound_handler.pitch_mod = amount

func get_mod_total_amount(
		mod_amounts: Array[float],
		mixing: AudioMSound.Mixing = AudioMSound.Mixing.ADD
) -> float:
	var amount: float = 0
	
	if not (sound is AudioMSoundComposition):
		return amount

	for mod_index in mod_amounts.size():
		var param_value = mod_amounts[mod_index] \
				* get_mod_state(mod_index)
		match mixing:
			AudioMSound.Mixing.ADD:
				amount += param_value
			AudioMSound.Mixing.MAX:
				amount = max(amount, param_value)
			AudioMSound.Mixing.MIN:
				amount = min(amount, param_value)
	
	return amount

func get_parameter(_name: String) -> float:
	if not (sound is AudioMSoundComposition):
		return 0
	return param_state.get_parameter(_name)

func get_parameter_name(mod_index: int) -> String:
	if not (sound is AudioMSoundComposition):
		return ""
	if not ("name" in sound.parameters[mod_index]):
		return ""
	return sound.parameters[mod_index].name

func get_mod_state(mod_index: int) -> float:
	if not (sound is AudioMSoundComposition):
		return 0
	
	match mod_list[mod_index].group:
		ModulationSource.LOCAL_PARAMETER:
			return param_state.get_parameter_by_index(mod_list[mod_index].group_index)
		ModulationSource.GLOBAL_PARAMETER:
			return AudioM.param_state.get_parameter(get_parameter_name(mod_index))
	
	return 0

func set_parameter(_name: String, value: float, ignore_seek: bool = false) -> void:
	param_state.set_parameter(_name, value, ignore_seek)

func has_parameter(_name: String) -> bool:
	if not (sound is AudioMSoundComposition):
		return false
	for param in sound.parameters:
		if param.name == _name:
			return true
	return false

func has_global_parameters() -> bool:
	if not (sound is AudioMSoundComposition):
		return false
	for param in sound.parameters:
		if param.global:
			return true
	return false

func play(
		offset: float = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.MEDIUM
) -> void:
	if is_stopping:
		return
	if sound is AudioMSound:
		return play_sound(sound, offset, 0, default_priority)
	elif sound is AudioMSoundComposition:
		if not is_playing():
			volume_fade_in = 1
			volume_fade_out = 1
			start_fade_in()
		
		if sound.repeat:
			repeat_time = 0
			repeat = true
			play_composition(sound, offset, default_priority)
		else:
			play_composition(sound, offset, default_priority)

func play_composition(
		_sound: AudioMSoundComposition,
		offset: float = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.MEDIUM
) -> void:
	for layer_index in _sound.layers.size():
		play_sound(_sound.layers[layer_index], offset, layer_index, default_priority)

func play_sound(
		_sound: AudioMSound,
		offset: float = 0,
		layer_index: int = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.MEDIUM
) -> void:
	var playback_ref: AudioMPlaybackReference = AudioM.reserve_channel(
			_sound, default_priority, position_type)

	if not playback_ref: return

	playback_ref.done.connect(_on_playback_ref_done.bind(playback_ref, layer_index))
	playback_refs.append(playback_ref)
	
	_playback_ref_created.emit(playback_ref)
	
	if not (layer_index in playback_refs_map):
		playback_refs_map[layer_index] = []
	playback_refs_map[layer_index].append(playback_ref)
	
	playback_ref.sound_handler.ignore_fade_in = is_override_enter_time()
	playback_ref.sound_handler.ignore_fade_out = is_override_leave_time()

	update_fade_in_levels()
	update_fade_out_levels()
	apply_layer_mods(layer_index)
	update_mix()

	playback_ref.start_playback(offset)

func stop() -> void:
	if is_stopping \
			or not is_playing() \
			or (fade_out_tween and fade_out_tween.is_running()):
		return

	repeat = false
	is_stopping = true
	stopping.emit()
	start_fade_out()

func force_stop() -> void:
	repeat = false
	repeat_time = 0

	if not is_stopping and not is_playing():
		return

	if is_playing() and is_interrupt_voices_on_stop():
		stop_fade_in()
		stop_fade_out()
		
		# NOTE: stop() removes items from the array, so it needs to be cloned
		var playback_refs_copy = playback_refs.duplicate()
		for playback_ref in playback_refs_copy:
			if playback_ref and not playback_ref.is_done:
				playback_ref.stop()
	
	is_stopping = false
	stopped.emit()

func is_playing() -> bool:
	return playback_refs.size() > 0 or is_repeating()

func is_repeating() -> bool:
	return sound is AudioMSoundComposition and sound.repeat and repeat

func is_override_enter_time() -> bool:
	return sound is AudioMSoundComposition and sound.override_enter_time \
			and sound.enter_time > 0

func is_override_leave_time() -> bool:
	return sound is AudioMSoundComposition and sound.override_leave_time \
			and sound.leave_time > 0

func is_interrupt_voices_on_stop() -> bool:
	return not (
			sound is AudioMSoundComposition \
			and sound.repeat \
			and not sound.interrupt_voices_on_stop
			and not is_override_leave_time()
	)

func create_fade_in_tween() -> void:
	stop_fade_in()
	fade_in_tween = get_tree().create_tween()
	fade_in_tween.finished.connect(_on_fade_in_tween_finished)

func create_fade_out_tween() -> void:
	stop_fade_out()
	fade_out_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fade_out_tween.finished.connect(_on_fade_out_tween_finished)

func start_fade_in() -> void:
	if is_override_enter_time() and sound.enter_time > 0:
		volume_fade_in = 0
		create_fade_in_tween()
		fade_in_tween.tween_property(self, "volume_fade_in", 1, sound.enter_time)

func start_fade_out() -> void:
	if is_override_leave_time() and sound.leave_time > 0:
		volume_fade_out = 1
		create_fade_out_tween()
		fade_out_tween.tween_property(self, "volume_fade_out", 0, sound.leave_time)
	else:
		force_stop()

func stop_fade_in() -> void:
	if fade_in_tween && fade_in_tween.is_running(): fade_in_tween.stop()

func stop_fade_out() -> void:
	if fade_out_tween && fade_out_tween.is_running(): fade_out_tween.stop()

func update_mix(_live_change: bool = false) -> void:
	if sound is AudioMSoundComposition:
		for playback_ref in playback_refs:
			if not sound.affect_active_voices and playback_ref.is_playing:
				continue
			playback_ref.sound_handler.volume_mix = sound.volume \
					+ get_mod_total_amount(
							composition_volume_mods,
							sound.volume_mod_mixing
					)
			playback_ref.sound_handler.pitch_mix = sound.pitch \
					+ get_mod_total_amount(
							composition_pitch_mods,
							sound.pitch_mod_mixing
					)

func update_fade_in_levels() -> void:
	if sound is AudioMSoundComposition and sound.override_enter_time:
		for playback_ref in playback_refs:
			playback_ref.sound_handler.volume_fade_in = volume_fade_in

func update_fade_out_levels() -> void:
	if sound is AudioMSoundComposition and sound.override_enter_time:
		for playback_ref in playback_refs:
			playback_ref.sound_handler.volume_fade_out = volume_fade_out

## Returns the playback position of an active layer by [param active_layer_index].
## [param active_layer_index] corresponds to the position of the layer in the active layer list,
## which is ordered by runtime (descending).
## If there is no active layer, the position will be [code]0[/code].
func get_playback_position(active_layer_index: int = 0) -> float:
	if active_layer_index < 0 or active_layer_index >= playback_refs.size():
		return 0
	return playback_refs[active_layer_index].sound_handler.player.get_playback_position()

func get_layer_delay(active_layer_index: int = 1) -> float:
	if active_layer_index <= 0 \
			or active_layer_index >= playback_refs.size() \
			or not playback_refs[active_layer_index - 1].sound_handler.player.is_playing() \
			or not playback_refs[active_layer_index].sound_handler.player.is_playing():
		return 0.0
	return playback_refs[active_layer_index].sound_handler.player.get_playback_position() \
			- playback_refs[active_layer_index - 1].sound_handler.player.get_playback_position()

func _on_playback_ref_done(playback_ref: AudioMPlaybackReference, layer_index: int) -> void:
	playback_refs.erase(playback_ref)
	if playback_refs_map[layer_index]:
		playback_refs_map[layer_index].erase(playback_ref)
	if not is_playing():
		done.emit()

func _on_local_param_change(_name: String) -> void:
	apply_mods()

func _on_global_param_change(_name: String) -> void:
	if has_parameter(_name):
		apply_mods()

func _on_fade_in_tween_finished() -> void:
	pass

func _on_fade_out_tween_finished() -> void:
	force_stop()

func _on_sound_volume_changed() -> void:
	update_mix(true)

func _on_sound_pitch_changed() -> void:
	update_mix(true)
