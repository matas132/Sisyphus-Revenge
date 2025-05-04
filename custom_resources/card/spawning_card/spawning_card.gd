class_name SpawningCard
extends Card

@export_file var entity_file_path : String

func use_card(entity_spawning_node : Node)->void:
	
	var spawn_pos : Vector2 = entity_spawning_node.get_viewport().get_mouse_position()
	
	
	var spawned_entity : Node2D = load(entity_file_path).instantiate()
	
	entity_spawning_node.add_child(spawned_entity)
	
	if sound_path != null && sound_path != "":
		AudioM.play(sound_path)
	
	
	if self is SpellCard:
		if self.instant_use:
			spawn_pos = Vector2.ZERO
	
	
	spawned_entity.global_position = spawn_pos
	
	
	
	if spawned_entity.has_method("init"):
		spawned_entity.init()
