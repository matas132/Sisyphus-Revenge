class_name LeftHand
extends BossPart
@onready var swing_sound: AudioMEventInstance2D = $SwingSound
@onready var hit_sound: AudioMEventInstance2D = $HitSound

func _ready() -> void:
	part_type  = PartType.LEFT_HAND
	spawn_area = get_parent().get_node("LeftArea")
	
	
	
	init()

# You can override the base punch for extra VFX or sound:
func do_left_punch() -> void:
	var has_target := false
	
	for b in $HurtBox.get_overlapping_bodies():
		if b is PlayerUnit:
			has_target = true
			break
	
	if not has_target:
		return  # No need to animate or do anything if no PlayerUnit is in range
	
	sprite.attack()
	swing_sound.play()
	await get_tree().create_timer(0.6).timeout  # sync VFX
	hit_sound.play()
	
	for b in $HurtBox.get_overlapping_bodies():
		if b is PlayerUnit:
			b.take_damage(damage)
			b.apply_knockback(global_position, 0.2, 120.0)
	
	await get_tree().create_timer(0.4).timeout  # sync VFX

	
	#if has_node("AnimationPlayer"):
	#	$AnimationPlayer.play("punch_recover")
	sprite.idle()
