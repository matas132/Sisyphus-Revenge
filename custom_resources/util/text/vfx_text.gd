class_name VFXtext
extends Resource


@export_multiline var text : String = ""

@export var position : Vector2

@export var rotation : float = randf_range(-20,20)

@export var font_color : Color = Color("c8a600")
@export var font_size : int = 40
@export var ordering : int = 0
@export var font : Font = load("res://assets/font/AntroposFreefont-BW2G.ttf")

@export var fade_time : float = 2
