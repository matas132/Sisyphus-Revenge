extends Control
@onready var h_box_container: HBoxContainer = $"../Hand/HBoxContainer"
@onready var reroll_cards_button: Button = $RerollCardsButton
@onready var reroll_cards_cooldown_timer: Timer = $RerollCardsCooldownTimer
@onready var card_giver: CardGiver = $"../../CardGiver"
@onready var time_until_reroll_cooldown_over: TextureProgressBar = $TimeUntilRerollCooldownOver



func _on_reroll_cards_cooldown_timer_timeout() -> void:
	reroll_cards_button.disabled = false


func _on_reroll_cards_button_pressed() -> void:
	reroll_cards_button.disabled = true
	reroll_cards_cooldown_timer.start()
	var card_count : int = 0
	for child in h_box_container.get_children():
		child.queue_free()
		card_count+=1
	
	for _i in card_count:
		card_giver.add_card()
	

func _process(_delta: float) -> void:
	time_until_reroll_cooldown_over.max_value = reroll_cards_cooldown_timer.wait_time
	time_until_reroll_cooldown_over.value = reroll_cards_cooldown_timer.wait_time - reroll_cards_cooldown_timer.time_left
