extends RefCounted
class_name AudioMPlaybackReference

signal done

var sound_handler: AudioMSoundHandler
var is_playing := false
var is_done := false
var is_stopping := false

func _init(handler: AudioMSoundHandler) -> void:
	self.sound_handler = handler
	connect_signals()

func connect_signals() -> void:
	sound_handler.started.connect(_on_sound_started)
	sound_handler.finished.connect(_on_sound_finished)
	sound_handler.stopping.connect(_on_sound_stopping)
	sound_handler.stopped.connect(_on_sound_stopped)
	sound_handler.tree_exited.connect(_on_sound_tree_exited)

func disconnect_signals() -> void:
	sound_handler.started.disconnect(_on_sound_started)
	sound_handler.finished.disconnect(_on_sound_finished)
	sound_handler.stopping.disconnect(_on_sound_stopping)
	sound_handler.stopped.disconnect(_on_sound_stopped)
	sound_handler.tree_exited.disconnect(_on_sound_tree_exited)

func start_playback(offset: float = 0) -> void:
	if sound_handler: sound_handler.start_playback(offset)

func stop() -> void:
	if sound_handler: sound_handler.stop()

func drop() -> void:
	disconnect_signals()
	sound_handler = null
	is_playing = false
	is_done = true
	is_stopping = false
	done.emit()

func _on_sound_started() -> void:
	is_playing = true

func _on_sound_finished() -> void:
	drop()

func _on_sound_stopping() -> void:
	is_stopping = true

func _on_sound_stopped() -> void:
	drop()

func _on_sound_tree_exited() -> void:
	drop()
