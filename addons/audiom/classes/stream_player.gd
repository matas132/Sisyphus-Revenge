class_name AudioMStreamPlayer
extends Node

signal finished

# AudioM properties

var player: Variant

# Shared properties

var autoplay: float:
	get:
		return player.autoplay
	set(value):
		player.autoplay = value
var bus: StringName:
	get:
		return player.bus
	set(value):
		player.bus = value
var max_polyphony: int:
	get:
		return player.max_polyphony
	set(value):
		player.max_polyphony = value
var pitch_scale: float:
	get:
		return player.pitch_scale
	set(value):
		player.pitch_scale = value
var playback_type: AudioServer.PlaybackType:
	get:
		return player.playback_type
	set(value):
		player.playback_type = value
var playing: bool:
	get:
		return player.playing
	set(value):
		player.playing = value
var stream: AudioStream:
	get:
		return player.stream
	set(value):
		player.stream = value
var stream_paused: bool:
	get:
		return player.stream_paused
	set(value):
		player.stream_paused = value
var volume_db: float:
	get:
		return player.volume_db
	set(value):
		player.volume_db = value
var volume_linear: float:
	get:
		return player.volume_linear
	set(value):
		player.volume_linear = value

# Global properties

var mix_target: AudioStreamPlayer.MixTarget:
	get:
		return player.mix_target
	set(value):
		player.mix_target = value

# 2D and 3D properties

var area_mask: int:
	get:
		return player.area_mask
	set(value):
		player.area_mask = value
var max_distance: float:
	get:
		return player.max_distance
	set(value):
		player.max_distance = value
var panning_strength: float:
	get:
		return player.panning_strength
	set(value):
		player.panning_strength = value

# 2D properties

var attenuation: float:
	get:
		return player.attenuation
	set(value):
		player.attenuation = value

# 3D properties

# TODO: link 3D properties
#var attenuation_filter_cutoff_hz
#var attenuation_filter_db
#var attenuation_model
#var doppler_tracking
#var emission_angle_degrees
#var emission_angle_enabled
#var emission_angle_filter_attenuation_db
#var max_db
#var unit_size

func _init(type: Variant) -> void:
	match type:
		AudioStreamPlayer:
			player = AudioStreamPlayer.new()
			add_child(player)
		AudioStreamPlayer2D:
			player = AudioStreamPlayer2D.new()
		#AudioStreamPlayer3D:
			#player = AudioStreamPlayer3D.new()
		_:
			assert(false, "type must be an AudioStreamPlayer, AudioStreamPlayer2D")

func _ready() -> void:
	player.finished.connect(_on_player_finished)

func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE and player:
		player.queue_free()

func is_playing() -> bool:
	return player.is_playing()

func get_playback_position() -> float:
	return player.get_playback_position()

func get_stream_playback() -> AudioStreamPlayback:
	return player.get_stream_playback()

func has_stream_playback() -> bool:
	return player.has_stream_playback()

func play(from_position: float) -> void:
	player.play(from_position)

func seek(to_position: float) -> void:
	player.seek(to_position)

func stop():
	player.stop()

func _on_player_finished() -> void:
	finished.emit()
