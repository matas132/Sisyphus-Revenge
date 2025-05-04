extends Area2D


func _on_damage_timeout() -> void:
	for body in get_overlapping_bodies():
		if body is BaseEntity:
			body.take_damage(9001)
