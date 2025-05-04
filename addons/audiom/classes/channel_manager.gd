class_name AudioMChannelManager
extends Node

@export var channel_count = 1:
	set(value):
		channel_count = value
		if is_node_ready():
			create_channels()

@export var position_type: AudioMChannel.PositionType

func _ready() -> void:
	if get_child_count() == 0:
		create_channels()

func create_channels() -> void:
	if get_child_count() > 0:
		for child in get_children():
			child.queue_free()
	for i in channel_count:
		var channel := AudioMChannel.new()
		channel.position_type = position_type
		add_child(channel)

func get_channel(priority: AudioMSound.Priority) -> AudioMChannel:
	var channel: AudioMChannel = get_first_available_channel()
	if not channel:
		channel = get_oldest_channel(priority)
		if not channel:
			return
	return channel

func get_first_available_channel() -> AudioMChannel:
	for channel: AudioMChannel in get_children():
		if channel.state != AudioMChannel.AVAILABLE:
			continue
			
		return channel
	
	return null

func get_oldest_channel(priority: AudioMSound.Priority) -> AudioMChannel:
	var oldest: AudioMChannel = null
	var overridable_range = (
		priority if priority < AudioMSound.Priority.HIGH
		else AudioMSound.Priority.MEDIUM
	)
	for p in overridable_range:
		for channel: AudioMChannel in get_children():
			if (channel.priority - 1 > p) \
					or channel.state == AudioMChannel.RESERVED:
				continue
			
			if not oldest or channel.runtime > oldest.runtime:
				oldest = channel
		if oldest:
			break
	
	return oldest

func get_priority(sound: AudioMSound, default_priority: AudioMSound.Priority) -> AudioMSound.Priority:
	return (
			sound.priority if sound.priority != AudioMSound.Priority.AUTO
			else default_priority if default_priority != AudioMSound.Priority.AUTO
			else AudioMSound.Priority.LOW
	)

func play(
		sound: AudioMSound,
		offset: float = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> AudioMPlaybackReference:
	if not sound: return
	
	var priority = get_priority(sound, default_priority)
	var channel = get_channel(priority)
	if not channel:
		return

	return channel.play(sound, offset, priority)

func stop_all() -> void:
	for channel: AudioMChannel in get_children():
		channel.stop()

func reserve_channel(
		sound: AudioMSound,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> AudioMPlaybackReference:
	if not sound: return
	
	var priority = get_priority(sound, default_priority)
	var channel = get_channel(priority)
	if not channel:
		return

	return channel.reserve(sound, priority)
