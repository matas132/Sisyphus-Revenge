class_name CardButton
extends Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var title: Label = $MarginContainer/Title
@onready var image: TextureRect = $Image
@onready var description : RichTextLabel = $PopUpControl/RichTextLabel
@onready var popup: Control = $PopUpControl
@export var card_data : Card
@onready var hover_tint: ColorRect = $HoverTint
@onready var toggle_tint: ColorRect = $ToggleTint
@onready var show_desc: Timer = $ShowDesc
@onready var desc_image: TextureRect = $DescImage

var is_flipped := false

func _ready() -> void:
	desc_image.visible = false
	hover_tint.visible = false
	toggle_tint.visible = false

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		await get_tree().process_frame
		AudioM.play("SFX/UI/CardSelect")
		toggle_tint.visible = true
		EventHandler.card_selected.emit(self)
		
		GlobalVar.GameState.selected_card = self
		
		animation_player.play("selected")
		
	else:
		toggle_tint.visible = false
		GlobalVar.GameState.selected_card = null
		animation_player.play("unselected")
	
	await get_tree().process_frame
	await get_tree().process_frame
	if GlobalVar.GameState.selected_card == null:
		AudioM.play("SFX/UI/CardCancel")

func init_card()->void:
	popup.visible = false
	if card_data ==null:
		return
	
	if card_data.title !=null:
		title.text = card_data.title
	if card_data.image !=null:
		image.texture = card_data.image
	if card_data.desc_image != null:
		desc_image.texture = card_data.desc_image
	

func remove()->void:
	queue_free()
	


#func _on_popup_panel_mouse_entered() -> void:
	#return
	##print("Mouse Entered")
	#if is_flipped and card_data.description == "":
		#return
	#
	## 1. Update the text
	#description.bbcode_enabled = true
	#description.text = card_data.description
	#
	## 2. Wait one frame so the label re‑flows
	#await get_tree().process_frame # wait 1 frame so size updates
	#
	#description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#description.fit_content = true
	#
	## Now the label’s rect_min_size equals its content size
	#var padding = Vector2(16, 16)
	#var content_size = description.get_minimum_size()
	#popup.custom_minimum_size = content_size + padding
	#
	##popup.position = Vector2(200, -popup.custom_minimum_size.y)
	#popup.visible = true
#
#
#func _on_popup_panel_mouse_exited() -> void:
	#return
	##return
	##print("Mouse Exited")
	##popup.custom_minimum_size = Vector2.ZERO
	#popup.visible = false
#
#func _on_flip_pressed() -> void:
	#is_flipped = !is_flipped
	#_animate_flip()
#
#func _animate_flip():
	#var tween = create_tween()
	## Shrink to zero width
	#tween.tween_property(self, "scale:x", 0, 0.2).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EASE_IN)
	## At midpoint, swap content
	#tween.tween_callback(Callable(self, "_swap_side"))
	## Expand back to full width
	#tween.tween_property(self, "scale:x", 1, 0.2).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EASE_OUT)
#
#func _swap_side():
	#$Image.visible = !is_flipped
	#$MarginContainer.visible = !is_flipped
	#$Back.visible = is_flipped
	#
	#if is_flipped:
		#$Back.get_node("RichTextLabel").text = card_data.description

var mouse_inside : bool = false

func _on_mouse_entered() -> void:
	
	AudioM.play("SFX/UI/CardHover")
	hover_tint.visible = true
	
	mouse_inside = true
	show_desc.start()

func _on_mouse_exited() -> void:
	
	hover_tint.visible = false
	mouse_inside = false
	desc_image.visible = false
	show_desc.stop()


func _on_show_desc_timeout() -> void:
	if mouse_inside:
		desc_image.visible = true
	else:
		desc_image.visible = false
