extends CheckButton



func _on_toggled(toggled_on: bool) -> void:
	GlobalVar.Settings.show_numbers = toggled_on
