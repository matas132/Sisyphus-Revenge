extends SoundButton

#@onready var credits: Control = $"../../../Credits"
@onready var credits: Control = $"../Credits"


func _on_pressed() -> void:
	credits.visible = true
	
