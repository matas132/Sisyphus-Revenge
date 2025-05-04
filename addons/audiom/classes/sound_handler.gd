class_name AudioMSoundHandler
extends Node

signal started
signal finished
signal stopping
signal stopped

@export var player: AudioMStreamPlayer
@export var sound: AudioMSound

var volume_main: float = 1:
	set(value):
		volume_main = value
		update_volume()
var volume_fade_in: float = 1:
	set(value):
		volume_fade_in = value
		update_volume()
var volume_fade_out: float = 1:
	set(value):
		volume_fade_out = value
		update_volume()
var volume_mod: float = 0:
	set(value):
		volume_mod = value
		update_volume()
var volume_mix: float = 1:
	set(value):
		volume_mix = value
		update_volume()
var volume: float:
	set(_value):
		push_warning("Cannot set volume directly")
	get:
		return (volume_main + volume_mod) * volume_mix * volume_fade_in * volume_fade_out
		
var pitch_main: float = 0:
	set(value):
		pitch_main = value
		update_pitch()
var pitch_mix: float = 0:
	set(value):
		pitch_mix = value
		update_pitch()
var pitch_mod: float = 0:
	set(value):
		pitch_mod = value
		update_pitch()
var pitch:
	set(_value):
		push_warning("Cannot set pitch directly")
	get:
		return pitch_main + pitch_mix + pitch_mod

var fade_in_tween: Tween
var fade_out_tween: Tween
var ignore_fade_in: bool = false
var ignore_fade_out: bool = false

func _ready() -> void:
	player.finished.connect(_on_stream_finished)

func initialize_new_sound(
		_sound: AudioMSound = sound
):
	if player.is_playing():
		force_stop()
	
	if _sound != sound:
		if OS.is_debug_build():
			# Watch resource changes in real time
			if sound:
				if sound.is_connected('volume_changed', _on_sound_volume_changed):
					sound.volume_changed.disconnect(_on_sound_volume_changed)
				if sound.is_connected('pitch_changed', _on_sound_pitch_changed):
					sound.pitch_changed.disconnect(_on_sound_pitch_changed)
				if (
						player.player is AudioStreamPlayer2D
						or player.player is AudioStreamPlayer3D
				):
					if sound.is_connected('max_distance_changed', _on_sound_max_distance_changed):
						sound.max_distance_changed.disconnect(_on_sound_max_distance_changed)
					if sound.is_connected('panning_strength_changed', _on_sound_panning_strength_changed):
						sound.panning_strength_changed.disconnect(_on_sound_panning_strength_changed)
				if player.player is AudioMEventInstance2D:
					if sound.is_connected('attenuation_changed', _on_sound_attenuation_changed):
						sound.attenuation_changed.disconnect(_on_sound_attenuation_changed)
			_sound.volume_changed.connect(_on_sound_volume_changed)
			_sound.pitch_changed.connect(_on_sound_pitch_changed)
			if (
					player.player is AudioStreamPlayer2D
					or player.player is AudioStreamPlayer3D
			):
				_sound.max_distance_changed.connect(_on_sound_max_distance_changed)
				_sound.panning_strength_changed.connect(_on_sound_panning_strength_changed)
			if player.player is AudioMEventInstance2D:
				_sound.attenuation_changed.connect(_on_sound_attenuation_changed)
		
		sound = _sound
		
	var rng := RandomNumberGenerator.new()
	
	volume_main = (
			sound.volume \
			- sound.volume_variation/2 + \
			rng.randf() * sound.volume_variation
	)
	volume_fade_in = 1
	volume_fade_out = 1
	volume_mod = 0
	volume_mix = 1
	
	pitch_main = (
			sound.pitch \
			- sound.pitch_variation/2 \
			+ rng.randf() * sound.pitch_variation
	)
	pitch_mod = 0
	
	if (
			player.player is AudioStreamPlayer2D
			or player.player is AudioStreamPlayer3D
	):
		player.max_distance = sound.max_distance
		player.panning_strength = sound.panning_strength
	
	if player.player is AudioStreamPlayer2D:
		player.attenuation = sound.attenuation
	
	ignore_fade_in = false
	ignore_fade_out = false
	
	if sound.stream.size() > 1:
		var stream_index := 0
		match sound.pool_behavior:
			AudioMSound.PoolBehavior.SHUFFLE:
				if sound.last_stream >= 0:
					stream_index = rng.randi() % (sound.stream.size() - 1)
					if stream_index >= sound.last_stream: stream_index += 1
				else:
					stream_index = rng.randi() % sound.stream.size()
			AudioMSound.PoolBehavior.RANDOMIZE:
				stream_index = rng.randi() % sound.stream.size()
			AudioMSound.PoolBehavior.SEQUENCIAL:
				stream_index = (sound.last_stream + 1) % sound.stream.size()
		player.stream = sound.stream[stream_index]
		sound.last_stream = stream_index
	elif sound.stream.size() == 1:
		player.stream = sound.stream[0]
	else:
		player.stream = null

	player.bus = AudioServer.get_bus_name(sound.bus)
	
	return AudioMPlaybackReference.new(self)

func play(
		_sound: AudioMSound = sound,
		offset: float = 0
) -> AudioMPlaybackReference:
	var ref = initialize_new_sound(_sound)
	
	start_playback(offset)
	
	return ref

func start_playback(offset: float = 0) -> void:
	if not ignore_fade_in and sound.enter_time > 0:
		volume_fade_in = 0
		create_fade_in_tween()
		fade_in_tween.tween_property(self, "volume_fade_in", 1, sound.enter_time)

	player.play(offset)
	started.emit()

func stop() -> void:
	if not player.is_playing() || (fade_out_tween && fade_out_tween.is_running()):
		return

	stopping.emit()

	if not ignore_fade_out and sound.leave_time > 0:
		volume_fade_out = 1
		create_fade_out_tween()
		fade_out_tween.tween_property(self, "volume_fade_out", 0, sound.leave_time)
	else:
		force_stop()

func stop_fade_in() -> void:
	if fade_in_tween && fade_in_tween.is_running(): fade_in_tween.stop()

func stop_fade_out() -> void:
	if fade_out_tween && fade_out_tween.is_running(): fade_out_tween.stop()

func force_stop() -> void:
	if not player.is_playing():
		return

	stop_fade_in()
	stop_fade_out()

	player.stop()
	stopped.emit()

func create_fade_in_tween() -> void:
	stop_fade_in()
	fade_in_tween = get_tree().create_tween()
	fade_in_tween.finished.connect(_on_fade_in_tween_finished)

func create_fade_out_tween() -> void:
	stop_fade_out()
	fade_out_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fade_out_tween.finished.connect(_on_fade_out_tween_finished)

func update_volume() -> void:
	player.volume_db = linear_to_db(max(volume, 0.0001))

func update_pitch() -> void:
	player.pitch_scale = pow(2, pitch / 12)

func _on_stream_finished() -> void:
	finished.emit()

func _on_fade_in_tween_finished() -> void:
	pass

func _on_fade_out_tween_finished() -> void:
	force_stop()
	
func _on_sound_volume_changed() -> void:
	volume_main = sound.volume

func _on_sound_pitch_changed() -> void:
	pitch_main = sound.pitch

func _on_sound_attenuation_changed() -> void:
	player.attenuation = sound.attenuation

func _on_sound_max_distance_changed() -> void:
	player.max_distance = sound.max_distance

func _on_sound_panning_strength_changed() -> void:
	player.panning_strength = sound.panning_strength
