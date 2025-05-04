extends TextureProgressBar
@onready var card_gain_timer: Timer = $"../CardGainTimer"


func _process(_delta: float) -> void:
	max_value = card_gain_timer.wait_time
	value = card_gain_timer.wait_time - card_gain_timer.time_left
