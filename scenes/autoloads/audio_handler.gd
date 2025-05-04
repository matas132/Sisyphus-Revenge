@tool
extends AudioMManager

const VERY_SHORT_LERP_TIME := 1.0


signal sound_finished # only called on the function that has the signal


func stop_all_sounds()->void:
	AudioM.stop_all()
	for child in $StreamPlayers.get_children():
		if child is AudioStreamPlayer:
			child.stop()
	
	
	# Music/Title
	# SFX/Unit/AttackSwing
	# SFX/Unit/ChaosRaiseDead
	# SFX/Unit/ChaosStun
	# Music/GameOver



# methods

# slowly transitions the specified sound to the specified volume, the volume must be linear
func lerp_to_specific_volume(sound: AudioStreamPlayerLinearVolume, specific_volume_level: float, lerp_time: float = VERY_SHORT_LERP_TIME) ->void:
	sound.hidden = false
	if !sound.playing:
		sound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(sound, "volume_level",specific_volume_level,lerp_time)

func lerp_to_specific_volume_mult(sound: AudioStreamPlayerLinearVolume, specific_volume_mult: float, lerp_time: float = VERY_SHORT_LERP_TIME) ->void:
	var tween = get_tree().create_tween()
	tween.tween_property(sound, "volume_mult",specific_volume_mult,lerp_time)




# 
func lerp_to_none(sound: AudioStreamPlayerLinearVolume) ->void:
	sound.hidden = true
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(sound, "volume_level",0.001,VERY_SHORT_LERP_TIME)
	await tween.finished
	sound.stop()

func lerp_from_none_to_max(sound : AudioStreamPlayerLinearVolume, lerp_time: float = VERY_SHORT_LERP_TIME) ->void: # sets the sounds volume db from 0 to 1
	sound.hidden = false
	sound.volume_level = 0.001
	
	
	if !sound.playing:
		sound.play()
	lerp_to_specific_volume(sound, 1, lerp_time)
	


func secretly_play_sound(sound: AudioStreamPlayerLinearVolume) ->void:
	sound.volume_level = 0.001
	sound.hidden = true
	
	
	if !sound.playing:
		sound.play()

func lerp_to_secretly_none(sound: AudioStreamPlayerLinearVolume) ->void: # lowers it to 0 but doesn't turn it off so its syncronised
	sound.hidden = true
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(sound, "volume_level",0.001,VERY_SHORT_LERP_TIME)


func start_sound_with_signal(sound)->void:
	sound.play()
	await sound.finished
	sound_finished.emit()
