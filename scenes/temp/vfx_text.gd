extends Node
const VFX_TEXT_LABEL = preload("res://scenes/ui/gameplay/vfx/vfx_text_label.tscn")
const NEW_SYSTEM_FONT = preload("res://assets/font/new_system_font.tres")
func _ready() -> void:
	EventHandler.create_text.connect(on_create_text)

func on_create_text(vfx : VFXtext)->void:
	if !GlobalVar.Settings.show_numbers:
		return
	
	
	var vfx_text : VfxText = VFX_TEXT_LABEL.instantiate()
	add_child(vfx_text)
	vfx_text.vfx_text_label.add_theme_font_size_override("font_size",vfx.font_size)
	vfx_text.vfx_text_label.add_theme_color_override("font_color", vfx.font_color)
	vfx_text.vfx_text_label.add_theme_font_override("font", vfx.font)
	vfx_text.z_index = vfx.ordering
	vfx_text.vfx_text_label.text = vfx.text
	
	vfx_text.global_position = vfx.position
	
	vfx_text.rotation_degrees += vfx.rotation
	
	
	
	#if text == "∞":
	#	vfx_text.vfx_text_label.add_theme_font_override("font",NEW_SYSTEM_FONT)
	
	create_tween().tween_property(vfx_text,"scale", Vector2(1.3,1.3), vfx.fade_time)
	var fade_out : PropertyTweener = create_tween().tween_property(vfx_text,"modulate", Color(1.0,1.0,1.0,0.0), vfx.fade_time)
	
	await fade_out.finished
	
	vfx_text.queue_free()
	
	
