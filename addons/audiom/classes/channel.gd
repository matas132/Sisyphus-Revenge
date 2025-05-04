class_name AudioMChannel
extends Node

enum {AVAILABLE, BUSY, RESERVED}

var state: int = AVAILABLE
var priority: int = 0
var runtime: float = 0
var player: AudioMStreamPlayer
var sound_handler: AudioMSoundHandler
var playback_ref: WeakRef

enum PositionType {
	GLOBAL,
	POSTIONAL_2D,
	#POSITONAL_3D
}
var position_type: PositionType

func _ready() -> void:
	player = AudioMStreamPlayer.new(get_player_type())
	add_child(player)
	sound_handler = AudioMSoundHandler.new()
	sound_handler.player = player
	sound_handler.started.connect(_on_sound_started)
	sound_handler.finished.connect(_on_sound_finished)
	sound_handler.stopped.connect(_on_sound_stopped)
	add_child(sound_handler)

func _process(delta: float) -> void:
	if state == BUSY:
		runtime += delta
	elif state == RESERVED and not playback_ref.get_ref():
		runtime = 0
		state = AVAILABLE

func reserve(
		sound: AudioMSound,
		_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> AudioMPlaybackReference:
	var ref: AudioMPlaybackReference = sound_handler.initialize_new_sound(sound)
	
	runtime = 0
	priority = _priority
	state = RESERVED
	playback_ref = weakref(ref)
	
	return ref

func play(
		sound: AudioMSound,
		offset: float = 0,
		_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> AudioMPlaybackReference:
	var ref: AudioMPlaybackReference = reserve(sound, _priority)
	
	sound_handler.start_playback(offset)

	return ref

func stop() -> void:
	sound_handler.force_stop()

func get_player_type() -> Variant:
	var player_type: Variant
	match position_type:
		PositionType.GLOBAL:
			player_type = AudioStreamPlayer
		PositionType.POSTIONAL_2D:
			player_type = AudioStreamPlayer2D
		#PositionType.POSTIONAL_3D:
			#player_type = AudioStreamPlayer3D
	return player_type

func _on_sound_started() -> void:
	runtime = 0
	state = BUSY

func _on_sound_finished() -> void:
	runtime = 0
	state = AVAILABLE
	
func _on_sound_stopped() -> void:
	if state == RESERVED:
		return
	runtime = 0
	state = AVAILABLE
