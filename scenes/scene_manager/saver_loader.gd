class_name SaverLoader
extends Node

@onready var volume_slider_master: HSlider = $"../Menu/AudioSettings/VolumeSlider"
@onready var volume_slider_music: HSlider = $"../Menu/AudioSettings/VolumeSlider2"
@onready var volume_slider_sfx: HSlider = $"../Menu/AudioSettings/VolumeSlider3"




func _ready() -> void:
	EventHandler.save_settings.connect(on_save_settings)


func on_save_settings()->void:
	var saved_settings : SavedSettings = SavedSettings.new()

	saved_settings.master_value = volume_slider_master.value
	saved_settings.music_value = volume_slider_music.value
	saved_settings.sfx_value = volume_slider_sfx.value
	ResourceSaver.save(saved_settings, "user://saved_settings.tres")

func on_load_settings()->void:
	var path = "user://saved_settings.tres"
	if FileAccess.file_exists(path):
		var saved_settings:SavedSettings = load(path)
		if saved_settings !=null:
			volume_slider_master.value = saved_settings.master_value
			volume_slider_music.value = saved_settings.music_value
			volume_slider_sfx.value = saved_settings.sfx_value
	



#func save_game():
#	var saved_game: SavedGame = SavedGame.new()
#	saved_game.master_value = volume_slider_master.value
#	saved_game.music_value = volume_slider_music.value
#	saved_game.sfx_value = volume_slider_sfx.value
#	saved_game.current_health= GlobalVar.current_health
#	saved_game.current_level = GlobalVar.current_level
#	ResourceSaver.save(saved_game, "user://savegame.tres")

#func load_game():
#	var path = "user://savegame.tres"
#	if FileAccess.file_exists(path):
#		var saved_game:SavedGame = load(path)
#		if saved_game !=null:
#			volume_slider_master.value = saved_game.master_value
#			volume_slider_music.value = saved_game.music_value
#			volume_slider_sfx.value = saved_game.sfx_value
			
#			GlobalVar.current_health = saved_game.current_health
#			GlobalVar.current_level = saved_game.current_level
