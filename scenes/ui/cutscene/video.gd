extends VideoStreamPlayer

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		finished.emit()
		accept_event()
		
