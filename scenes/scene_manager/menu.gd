class_name MenuHandler
extends CanvasLayer

# none of the menus have any logic to them, they are there to just display their stuff, all connections and logic is handled in this class

# TITLE SCREEN
@onready var title_screen: Control = $TitleScreen
#@onready var start_game_button: SoundButton = $TitleScreen/MarginContainer/VBoxContainer/StartGame
#@onready var settings_button: SoundButton = $TitleScreen/MarginContainer/VBoxContainer/Settings
#@onready var quit_button: SoundButton = $TitleScreen/MarginContainer/VBoxContainer/Quit
@onready var start_game_button: SoundButton = $TitleScreen/StartGame
@onready var settings_button: SoundButton = $TitleScreen/Settings
@onready var quit_button: SoundButton = $TitleScreen/Quit




# SETTINGS MENU
@onready var settings_menu: Control = $SettingsMenu
@onready var audio_settings_button: SoundButton = $SettingsMenu/MarginContainer/TextureRect/MarginContainer/VBoxContainer/AudioSettingsButton
@onready var to_title_button: SoundButton = $SettingsMenu/MarginContainer/TextureRect/MarginContainer/VBoxContainer/ToTitleButton

# AUDIO SETTINGS MENU
@onready var audio_settings: Control = $AudioSettings
#@onready var exit_settings_button: SoundButton = $AudioSettings/MarginContainer/TextureRect/VBoxContainer/ExitSettingsButton
@onready var exit_settings_button: SoundButton = $AudioSettings/ExitSettingsButton

# PAUSE MENU
@onready var pause_menu: Control = $PauseMenu
#@onready var back_to_game_pause_button: SoundButton = $PauseMenu/MarginContainer/TextureRect/VBoxContainer/ExitPausedMenu
#@onready var audio_settings_pause_button: SoundButton = $PauseMenu/MarginContainer/TextureRect/VBoxContainer/AudioSettings
#@onready var to_title_pause_button: SoundButton = $PauseMenu/MarginContainer/TextureRect/VBoxContainer/ToTitle
#@onready var pause_menu_quit_game_button: SoundButton = $PauseMenu/MarginContainer/TextureRect/VBoxContainer/QuitGame

@onready var pause_menu_quit_game_button: SoundButton = $PauseMenu/QuitGame
@onready var back_to_game_pause_button: SoundButton = $PauseMenu/ExitPausedMenu
@onready var audio_settings_pause_button: SoundButton = $PauseMenu/AudioSettings



var in_pause_menu := false

signal start_game

func _ready() -> void:
	connect_all_menu_signals()



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if title_screen.visible:
			return
#		elif audio_settings.visible:
#			_on_exit_audio_settings_pressed()
#			_on_pause_exit_pressed()
#		elif controls.visible:
#			_on_exit_control_settings_pressed()
#			_on_pause_exit_pressed()
		elif pause_menu.visible:
			_on_pause_exit_pressed()
		else :
			#_on_pause_exit_pressed()
			_on_pause_press()






# TITLE SCREEN
func on_start_game_button_pressed()->void:
	title_screen.visible = false
	
	start_game.emit()

func on_settings_button_pressed()->void:
	settings_menu.visible = true
	on_audio_settings_button_pressed()
	
func on_quit_button_pressed()->void:
	get_tree().quit()


# SETTINGS MENU
func on_to_title_button_pressed()->void:
	settings_menu.visible = false

func on_audio_settings_button_pressed()->void:
	settings_menu.visible = false
	pause_menu.visible = false
	audio_settings.visible = true


# AUDIO SETTINGS MENU
func on_exit_audio_settings_button_pressed()->void:
	EventHandler.save_settings.emit()
	audio_settings.visible = false
	if in_pause_menu:
		pause_menu.visible = true
	#else:
	#	settings_menu.visible = true
	


# PAUSE MENU 
func _on_pause_press() -> void: # entered pause menu
	#print("pause menu")
	set_game_paused(true)
	pause_menu.visible = true
	in_pause_menu = true

func _on_pause_exit_pressed()->void: # exited pause menu
	set_game_paused(false)
	pause_menu.visible = false
	in_pause_menu = false







func set_game_paused(paused: bool):
	get_tree().paused = paused

func connect_all_menu_signals()->void:
	
	# TITLE SCREEN
	start_game_button.pressed.connect(on_start_game_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	
	# SETTINGS MENU
	to_title_button.pressed.connect(on_to_title_button_pressed)
	audio_settings_button.pressed.connect(on_audio_settings_button_pressed)
	exit_settings_button.pressed.connect(on_exit_audio_settings_button_pressed)
	
	# PAUSE MENU
	back_to_game_pause_button.pressed.connect(_on_pause_exit_pressed)
	pause_menu_quit_game_button.pressed.connect(on_quit_button_pressed)
	audio_settings_pause_button.pressed.connect(on_audio_settings_button_pressed)
