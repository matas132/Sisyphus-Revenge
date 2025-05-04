@tool
class_name AudioMSound
extends AudioMEventResource

signal volume_changed
signal pitch_changed
signal attenuation_changed
signal max_distance_changed
signal panning_strength_changed

@export var stream: Array[AudioStream] = []
enum PoolBehavior {SHUFFLE, RANDOMIZE, SEQUENCIAL}
@export var pool_behavior: PoolBehavior = PoolBehavior.SHUFFLE:
	set(value):
		pool_behavior = value
		notify_property_list_changed()
enum Priority {
	## Picks priority based on the play method called
	## (from the audio manager: [b]Low[/b],
	## from an instance: [b]Medium[/b])
	AUTO,
	## Can only override voices of the same priority.
	## Recommended for short and subtle sounds.
	LOW,
	## Can override voices of lower or same priority.
	## Recommended for short but important sounds.
	MEDIUM,
	## Can only override voices of lower priority. Cannot be overriden.
	## Recommended for long or looping audio.
	HIGH
}
## Determines the persistence of the sound when out of audio channels.
@export var priority: Priority = Priority.AUTO
@export_range(0, 1.2, 0.01, "or_greater") var volume: float = 1:
	set(value):
		volume = value
		volume_changed.emit()
## Range of volume variation randomly applied to the sound.
## A value of 0 applies no volume variation, while 1.0 will randomly pick between a
## minimum of -0.5 and maximum of +0.5.
@export_range(0, 1) var volume_variation: float = 0
enum Mixing {ADD,MAX,MIN}
## Determines how volume modulations will mix together
@export var volume_mod_mixing: Mixing = Mixing.MAX

enum AudioBusIndex {Master}
@export var bus: AudioBusIndex = AudioBusIndex.Master

@export_custom(PROPERTY_HINT_NONE, "suffix:s") var enter_time: float = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var leave_time: float = 0.2
## Pitch offset in semitones.
@export_range(-60, 60, 0.01, "suffix:st") var pitch: float = 0:
	set(value):
		pitch = value
		pitch_changed.emit()
## Range of pitch variation randomly applied to the sound in semitones.
## A value of 0 applies no pitch variation, while 2.0 will randomly pick between a
## minimum of -1 and maximum of +1 semitone.
@export_range(0, 120, 0.01, "suffix:st") var pitch_variation: float = 0
## Determines how pitch modulations will mix together
@export var pitch_mod_mixing: Mixing = Mixing.ADD

@export_group("Position")
@export var attenuation: float = 1:
	set(value):
		attenuation = value
		attenuation_changed.emit()
@export var max_distance: float = 2000:
	set(value):
		max_distance = value
		max_distance_changed.emit()
@export var panning_strength: float = 1:
	set(value):
		panning_strength = value
		panning_strength_changed.emit()

var last_stream: int = -1

func _validate_property(property: Dictionary) -> void:
	if property.name == "stream":
		property.hint_string = "%d/%d:%s" % [
			TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE,
			"AudioStreamWAV,AudioStreamMP3,AudioStreamOggVorbis"
		]
	elif property.name == "bus":
		var options = ""
		for i in AudioServer.bus_count:
			if i > 0:
				options += ","
			options += AudioServer.get_bus_name(i)
		property.hint_string = options
