extends Button

@onready var game_completed_menu: CanvasLayer = $"../../.."
@onready var scene_manager: Node = $"../../../../.."


func _on_pressed() -> void:
	scene_manager.on_start_game()
	game_completed_menu.visible = false
