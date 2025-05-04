class_name CardHand
extends Control

const CARD_BUTTON = preload("res://scenes/ui/gameplay/card_system/card/card.tscn")

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	init_hand()

func init_hand()->void:
	for child : CardButton in h_box_container.get_children():
		child.init_card()

func add_card(card_data : Card)->void:
#	AudioM.play()
	AudioM.play("SFX/UI/CardNew")
	
	var card_button : CardButton = CARD_BUTTON.instantiate()
	card_button.card_data = card_data
	h_box_container.add_child(card_button)
	card_button.init_card()

func count_cards()->int:
	return h_box_container.get_child_count()
