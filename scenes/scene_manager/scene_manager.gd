extends Node
const GAME = preload("res://scenes/temp/temp_game.tscn")
const VIDEO_INTRO = preload("res://scenes/ui/cutscene/video_intro.tscn")
const VIDEO_ENDING = preload("res://scenes/ui/cutscene/video_ending.tscn")
@onready var menu: MenuHandler = $Menu
@onready var saver_loader: SaverLoader = $SaverLoader
@onready var game_scenes: Node = $GameScenes

@onready var video_canvas_layer: CanvasLayer = $GameScenes/Video

@onready var game_over_menu: CanvasLayer = $GameScenes/GameOverMenu
@onready var game_completed_menu: CanvasLayer = $GameScenes/GameCompletedMenu

@onready var title_music: AudioMEventInstance = $TitleMusic

@onready var game_over_music: AudioMEventInstance = $GameOverMusic


var game
var video : Control

func _ready():
	menu.start_game.connect(on_start_game_cutscene)
	saver_loader.on_load_settings()
	title_music.play()

func on_start_game_cutscene()->void:
	if video !=null:
		video.queue_free()
	
	title_music.stop()
	
	video = VIDEO_INTRO.instantiate()
	video_canvas_layer.add_child(video)
	video.grab_focus()
	await video.finished
	on_start_game()
	video.queue_free()

func on_start_game():
	if title_music.is_playing():
		title_music.stop()
	
	if game_over_music.is_playing():
		game_over_music.stop()
	
	if game !=null:
		game.queue_free()
	
	GlobalVar.GameState.score = 0
	game = GAME.instantiate()
	game_scenes.add_child(game)
	
	if !game.game_over.is_connected(on_game_over):
		game.game_over.connect(on_game_over)
	
	if !game.game_completed.is_connected(on_game_completed):
		game.game_completed.connect(on_game_completed)
		
	
	#print("game completed signal connected")

func on_game_over()->void:
	game_over_music.play()
	game_over_menu.show_menu()

func on_game_completed()->void:
	if video !=null:
		video.queue_free()
	
	video = VIDEO_ENDING.instantiate()
	video_canvas_layer.add_child(video)
	video.grab_focus()
	await video.finished
	video.queue_free()
	
	
	title_music.play()
	game_completed_menu.show_menu()
	#print("TODO thanks for playing")
