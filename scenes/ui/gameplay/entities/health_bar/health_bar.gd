class_name HealthBar
extends ProgressBar



func init(entity_max_health: float) ->void:
	max_value = entity_max_health
	value = entity_max_health
	if value == max_value:
		visible = false

func update_health_bar(new_health : float) ->void:
	value = new_health
	if value == max_value:
		visible = false
	else:
		visible = true
