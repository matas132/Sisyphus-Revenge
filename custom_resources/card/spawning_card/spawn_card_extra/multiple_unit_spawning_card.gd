extends SpawningCard

@export var unit_spawn_amount : int = 1



func use_card(entity_spawning_node : Node)->void:
	if entity_spawning_node.get_child_count() > 150:
		#print("more than 150 entities, despawning")
		#print(str(count_units(entity_spawning_node)))
		#print(str(count_enemies(entity_spawning_node)))
		return
	
	if sound_path != null && sound_path != "":
		AudioM.play(sound_path)
	
	
	var spawn_amount : int = unit_spawn_amount
	
	var unit_amount :int = count_units(entity_spawning_node)
	var enemy_amout :int = count_enemies(entity_spawning_node)
	if unit_amount <20:
		@warning_ignore("integer_division")
		spawn_amount += int((enemy_amout/5))
	
	
	for i in spawn_amount:
		
		
		var spawned_entity : Node2D = load(entity_file_path).instantiate()
		
		entity_spawning_node.add_child(spawned_entity)
		
		
		
		
		spawned_entity.global_position = entity_spawning_node.get_viewport().get_mouse_position() + Vector2(
			randf_range(-150,150),randf_range(-150,150))
		
		
		
		if spawned_entity.has_method("init"):
			spawned_entity.init()

func count_enemies(entity_spawning_node : Node)->int:
	var i : int = 0
	for child in entity_spawning_node.get_children():
		if child is Enemy:
			i+=1
	return i

func count_units(entity_spawning_node : Node)->int:
	var i : int = 0
	for child in entity_spawning_node.get_children():
		if child is PlayerUnit:
			i+=1
	return i
