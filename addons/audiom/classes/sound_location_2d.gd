class_name AudioMSoundLocation2D
extends Node2D

var player: AudioStreamPlayer2D

func _init(_player: AudioStreamPlayer2D) -> void:
	player = _player
	assert(_player, "player should be an AudioStreamPlayer2D")

func _ready() -> void:
	add_child(player)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# Release the player so it doesn't get destroyed
		release()

func release() -> void:
	if player != null:
		remove_child(player)
		player = null
