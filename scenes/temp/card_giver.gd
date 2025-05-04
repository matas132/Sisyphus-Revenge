class_name CardGiver
extends Node
@onready var card_gain_timer: Timer = $CardGainTimer
@onready var hand: CardHand = $"../GameUI/Hand"

@export var card_gain_interval : float = 0.0

@export var available_cards : Array[CardSpawn]



func _ready() -> void:
	card_gain_timer.start(card_gain_interval)


func _on_card_gain_timer_timeout() -> void:
	if hand.count_cards() >= 7:
		return
	
	add_card()
	
	card_gain_timer.start(card_gain_interval)
	
	

func add_card()->void:
	hand.add_card(get_rand_card(available_cards))
	


func get_rand_card(cards : Array[CardSpawn]) -> Card:
	var total_weight = 0
	for card in cards:
		total_weight += card.weight
	var random_value = randi() % total_weight
	var cumulative_weight = 0

	for card in cards:
		cumulative_weight += card.weight
		if random_value < cumulative_weight:
			return card.card
	
	return cards[0].card
