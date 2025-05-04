extends CanvasLayer
@onready var score_label: Label = $Control/VBoxContainer/ScoreLabel

func _ready() -> void:
	visible = false

func show_menu()->void:
	score_label.text = "Score: " + str(GlobalVar.GameState.score)
	visible = true
