extends Button
@onready var credits: Control = $".."

func _ready() -> void:
	credits.visible = false

func _on_pressed() -> void:
	credits.visible = false
