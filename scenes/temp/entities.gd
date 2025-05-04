extends Node2D

var kill_amount : int = 15

func _on_child_entered_tree(_node: Node) -> void:
	if get_child_count() < 150:
		return
	
	var player_units : Array[PlayerUnit] = []
	for child in get_children():
		if child is PlayerUnit:
			player_units.append(child)
	
	if player_units.size() < 70:
		return
	
	for i in kill_amount:
		player_units[i].take_damage(9001)
	
