class_name SoundButton
extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered_sound)
	pressed.connect(_on_pressed_sound)

func _on_mouse_entered_sound() ->void:
	AudioM.play('SFX/UI/Choose')

func _on_pressed_sound() -> void:
	AudioM.play('SFX/UI/Select')
