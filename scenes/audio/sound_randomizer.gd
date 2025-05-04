class_name RandomSFX
extends Node

func play() ->void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var randomStep = get_child(rng.randi_range(0, get_child_count() - 1))
	randomStep.play()
