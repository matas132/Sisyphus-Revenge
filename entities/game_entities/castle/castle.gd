class_name Castle
extends BaseEntity

signal defense_signal(enemy)

@onready var health_bar: HealthBar = $HealthBar
@onready var defense_area_2d: Area2D = $DefenseArea2D # New Area2D for enemy detection

signal game_over

func _ready() -> void:
	
	health = max_health
	health_bar.init(max_health)
	health_bar.update_health_bar(health)
	
	health_changed.connect(func(): health_bar.update_health_bar(health))

func _on_defense_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		# Iterate over all player units in the group and call their method
		for unit in get_tree().get_nodes_in_group("free_player_units"):
			if unit.has_method("_on_castle_defense_signal"):
				unit._on_castle_defense_signal(body)
			else:
				return


func die()->void:
	game_over.emit()
