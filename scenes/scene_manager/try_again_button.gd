extends Button
@onready var scene_manager: Node = $"../../../../.."
@onready var game_over_menu: CanvasLayer = $"../../.."


func _on_pressed() -> void:
	scene_manager.on_start_game()
	game_over_menu.visible = false
