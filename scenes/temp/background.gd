extends TextureRect
@onready var castle: Castle = $"../Castle"

const BG_DAMAGE_R = preload("res://assets/background/BG_damage_r.png")

func _on_castle_health_changed() -> void:
	if castle.health <= castle.max_health/2.0:
		texture = BG_DAMAGE_R
