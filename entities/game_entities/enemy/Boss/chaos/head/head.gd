class_name Head
extends BossPart
@onready var spawn_sound: AudioMEventInstance2D = $SpawnSound
@onready var stun_sound: AudioMEventInstance2D = $StunSound

func _ready() -> void:
	part_type  = PartType.HEAD
	spawn_area = get_parent().get_node("CenterArea")
	windup_time   = 2.0
	spawn_sound.play()
	init()

func do_head_stun() -> void:
	# play a shockwave animation
	#if has_node("AnimationPlayer"):
	#	$AnimationPlayer.play("stun_wave")
	
	var has_target := false
	
	for b in $HurtBox.get_overlapping_bodies():
		if b is PlayerUnit:
			has_target = true
			break
	
	if not has_target:
		return  # No need to animate or do anything if no PlayerUnit is in range
	
	sprite.attack()
	
	await get_tree().create_timer(0.57).timeout
	
	stun_sound.play()
	for b in $HurtBox.get_overlapping_bodies():
		if b is PlayerUnit:
			b.apply_stun(3)
	
	await get_tree().create_timer(0.43).timeout
	
	sprite.walk()
