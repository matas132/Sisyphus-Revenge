extends Node2D
@onready var entities: Node = $Entities
@onready var listener: AudioListener2D = $AudioListener2D

@onready var ambience_ins: AudioMEventInstance = $AmbienceIns
@onready var music_ins: AudioMEventInstance = $MusicIns
@onready var chorus_effect: AudioEffectChorus = AudioServer.get_bus_effect(
		AudioServer.get_bus_index("MusicChorus"), 0
)
@onready var castle: Castle = $Castle

const INPUT_BLOCK = preload("res://scenes/ui/other/input_block.tscn")

signal game_completed
signal game_over
func _ready() -> void:
	EventHandler.card_selected.connect(on_card_selected)
	listener.make_current()
	
	AudioM.set_parameter("boss", 0, true)
	chorus_effect.wet = 0
	ambience_ins.play()
	music_ins.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		#print("want to play card")
		if GlobalVar.GameState.selected_card != null:
			play_card()
			#print("playing card")
			

## when you have a card selected and press on the screen
func play_card()->void:
	var card_button : CardButton = GlobalVar.GameState.selected_card
	
	
	card_button.card_data.use_card(entities)
	
	card_button.remove()

## when you press a card, rightnow it just checks if the card is instant use and if it is then it activates it
func on_card_selected(card_button : CardButton)->void:
	if !(card_button.card_data is SpellCard):
		return
	var card : SpellCard = card_button.card_data
	
	if card.instant_use:
		card.use_card(entities)
		card_button.remove()
	


func _on_castle_game_over() -> void:
	music_ins.stop()
	game_over.emit()
	
	queue_free()


func _on_boss_wave() -> void:
	AudioM.set_parameter("boss", 1)
	create_tween().tween_property(chorus_effect, "wet", 0.4, 3)


func on_game_completed()->void:
	music_ins.stop()
	
	
	var vfx_text : VFXtext = VFXtext.new()
	vfx_text.text = "VICTORY ACHIEVED"
	vfx_text.position = Vector2(500.0,400.0)
	vfx_text.fade_time = 5
	vfx_text.font_size = 100
	vfx_text.ordering = 10
	vfx_text.font_color = Color("F4D03F")
	vfx_text.font = load("res://assets/font/AntroposFreefont-BW2G.ttf")
	vfx_text.rotation = 0.0
	EventHandler.create_text.emit(vfx_text)
	
	var inp = INPUT_BLOCK.instantiate()
	entities.add_child(inp)
	
	await get_tree().create_timer(5).timeout
	
	game_completed.emit()
	queue_free()
	
	
	
	
	
	
