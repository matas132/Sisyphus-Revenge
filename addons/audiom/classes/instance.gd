@tool
class_name AudioMInstance
extends Node

var manager: AudioMManager
var channel_manager_global: AudioMChannelManager
var channel_manager_2d: AudioMChannelManager
var param_state: AudioMParameterState

func add_manager(_manager: AudioMManager) -> void:
	if manager:
		remove_manager(manager)

	manager = _manager
	manager.channel_count_changed.connect(_on_channel_count_changed)
	channel_manager_global = AudioMChannelManager.new()
	channel_manager_global.channel_count = manager.channel_count
	add_child(channel_manager_global)
	channel_manager_2d = AudioMChannelManager.new()
	channel_manager_2d.channel_count = manager.channel_count_2d
	channel_manager_2d.position_type = AudioMChannel.PositionType.POSTIONAL_2D
	add_child(channel_manager_2d)
	param_state = AudioMParameterState.new()
	param_state.initialize(manager.global_parameters)
	add_child(param_state)

func remove_manager(_manager: AudioMManager) -> void:
	if manager:
		if manager.channel_count_changed.is_connected(_on_channel_count_changed):
			manager.channel_count_changed.disconnect(_on_channel_count_changed)
	
	if channel_manager_global:
		channel_manager_global.queue_free()
	
	if channel_manager_2d:
		channel_manager_global.queue_free()
	
	if param_state:
		param_state.queue_free()

func get_event_resource(event_path: String) -> AudioMEventResource:
	if not assert_has_manager():
		return

	if not manager.event_tree:
		assert(manager.event_tree, "Event Tree is missing, define it in the inspector")
		return

	var event: AudioMEvent = manager.event_tree.get_node(event_path)

	assert(event, event_path + " Audio Event not found")
	if not event: return

	return event.sound

func play(event_path: String, offset: float = 0) -> void:
	if not assert_has_manager():
		return
	
	var resource = get_event_resource(event_path)
	if resource is AudioMSound:
		channel_manager_global.play(resource, offset, AudioMSound.Priority.LOW)
	elif resource is AudioMSoundComposition:
		var one_shot_instance = AudioMEventInstance.new()
		one_shot_instance.event_path = event_path
		add_child(one_shot_instance)
		one_shot_instance.done.connect(_on_one_shot_instance_done.bind(one_shot_instance))
		one_shot_instance.play(offset, AudioMSound.Priority.LOW)

func play_sound(
		sound: AudioMSound,
		offset: float = 0,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.LOW
) -> AudioMPlaybackReference:
	if not assert_has_manager():
		return
	
	return channel_manager_global.play(sound, offset, default_priority)

func reserve_channel(
		sound: AudioMSound,
		default_priority: AudioMSound.Priority = AudioMSound.Priority.LOW,
		position_type: AudioMChannel.PositionType = AudioMChannel.PositionType.GLOBAL
) -> AudioMPlaybackReference:
	if not assert_has_manager():
		return
	
	return get_channel_manager(position_type).reserve_channel(sound, default_priority)

func stop_all() -> void:
	channel_manager_global.stop_all()
	channel_manager_2d.stop_all()

func create_instance(event_path: String) -> AudioMEventInstance:
	var instance = AudioMEventInstance.new()
	instance.event_path = event_path
	return instance

func get_channel_manager(position_type: AudioMChannel.PositionType) -> AudioMChannelManager:
	match position_type:
		AudioMChannel.PositionType.GLOBAL:
			return channel_manager_global
		AudioMChannel.PositionType.POSTIONAL_2D:
			return channel_manager_2d
		_:
			assert(false, "invalid AudioMChannel.PositionType")
			return null

func get_parameter(_name: String) -> float:
	if not assert_has_manager():
		return 0
	
	return param_state.get_parameter(_name)

func set_parameter(_name: String, value: float, ignore_seek: bool = false) -> void:
	if not assert_has_manager():
		return
	
	param_state.set_parameter(_name, value, ignore_seek)

func assert_has_manager() -> bool:
	assert(manager, "No AudioMManager in tree")
	return true if manager else false

func _on_channel_count_changed() -> void:
	if channel_manager_global: channel_manager_global.channel_count = manager.channel_count
	if channel_manager_2d: channel_manager_2d.channel_count = manager.channel_count_2d

func _on_one_shot_instance_done(one_shot_instance: AudioMEventInstance) -> void:
	one_shot_instance.queue_free()
