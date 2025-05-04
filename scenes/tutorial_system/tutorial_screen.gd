extends Control

@onready var text_1: Label = $Text1
@onready var text_2: Label = $Text2
@onready var text_3: Label = $Text3
@onready var text_4: Label = $Text4

@onready var texts=[
	text_1,
	text_2,
	text_3,
	text_4,
]
@onready var high_light_1: PointLight2D = $HighLight1
@onready var high_light_2: PointLight2D = $HighLight2
@onready var high_light_3: PointLight2D = $HighLight3
@onready var high_light_4: PointLight2D = $HighLight4

@onready var highlights = [
	high_light_1,
	high_light_2,
	high_light_3,
	high_light_4,
]
var clicks := 0

var highlight 
var text_tutorial
# TODO, remake this with inheritance, until the next game jam
var ready_for_tutorial := false
func _ready() -> void:
	get_tree().paused = true
	clicks = 0
	highlight = highlights[clicks] as PointLight2D
	text_tutorial = texts[clicks] as Label
	await get_tree().create_timer(1.7,true).timeout
	ready_for_tutorial = true


func _input(event: InputEvent) -> void:
	if ready_for_tutorial:
		if event.is_action_pressed("left_click"):
			on_pressed()


func on_pressed() -> void:
	highlight.visible = false
	text_tutorial.visible = false
	if clicks < texts.size()-1:
		clicks+=1
		highlight = highlights[clicks] as PointLight2D
		text_tutorial = texts[clicks] as Label
		highlight.visible = true
		text_tutorial.visible = true
		ready_for_tutorial = false
		await get_tree().create_timer(0.8,true).timeout
		ready_for_tutorial = true
	else:
		get_tree().paused = false
		queue_free()
	
