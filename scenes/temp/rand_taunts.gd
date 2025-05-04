extends Node

@onready var entities: Node2D = $"../Entities"

var soldier_taunts : Array[String] = [
	"Death to Olympus!",
	"Not even the powers of the gods can break our spirits!",
	"As flies to careless children are we to the gods… \nThey kill us for sport.",
	"For too long have the gods seemed to rule without equal. \nNow that time is over.",
	"You cannot stop us. If I fall more will take up my spear.",
	"There is no god of freedom. For if there were they would be on our side!",
	"Send your plagues, your storms of fire, your whirlwinds… \nWe have endured them before.",
	#"You sought to teach us a lesson by punishing Sisyphus. \nInstead you crowned him as ruler of our rebellion!",
#	"Strike me down if you must. My children shall take up the fight, \nyou cannot rob them of what they know to be true.",
	"We fight at Olympus today, but this war is to free all lands from the tyranny of Zeus!",
	"No more sacrifices! No more killing in the name of gods who treat us like playthings!",
	#"Fight us all you want but there will come a day where there will be one too many. \nWhere we will crest over the slopes of Olympus and seize our freedom for once and for all!"
]

var monster_taunts : Array[String] = [
	"We are victims of gods, cursed by those more powerful into fearful, horrible things.",
	"We will have our revenge!",
	"Sisyphus has promised us a life where we will not suffer by the whims of Olympians!",
	"Scions of Kronos, embrace your end!",
	"We are the children of Chaos. We will be your end.",
	"Rawr!",
	"Before we were pitted against mortals. \nNow we are allies against our common foe.",
	"No more petty punishments for minor sins. \nNo more suffering from jealous gods!"
]

func _on_taunt_timer_timeout() -> void:
	var enemies : Array[Enemy] = []
	
	for child in entities.get_children():
		if child is Enemy:
			enemies.append(child)
	
	if enemies.size() == 0:
		return
	
	var rand_enemy : Enemy = enemies[randi_range(0, enemies.size()-1)]
	
	if is_soldier(rand_enemy):
		
		var vfx_text : VFXtext = VFXtext.new()
		vfx_text.text = str(soldier_taunts[randi_range(0, soldier_taunts.size()-1)])
		vfx_text.position = rand_enemy.global_position + Vector2(randf_range(-40,40),-60)
		vfx_text.fade_time = 6
		vfx_text.font_size = 20
		vfx_text.font_color = Color("b12700")
		vfx_text.font = load("res://assets/font/AntroposFreefont-BW2G.ttf")
		vfx_text.rotation = randf_range(-20,20)
		vfx_text.ordering = 2
		EventHandler.create_text.emit(vfx_text)
		
	elif is_monster(rand_enemy):
		
		
		
		var vfx_text : VFXtext = VFXtext.new()
		vfx_text.text = str(monster_taunts[randi_range(0, monster_taunts.size()-1)])
		vfx_text.position = rand_enemy.global_position + Vector2(randf_range(-40,40),-60)
		vfx_text.fade_time = 6
		vfx_text.font_size = 20
		vfx_text.font_color = Color("b12700")
		vfx_text.font = load("res://assets/font/AntroposFreefont-BW2G.ttf")
		vfx_text.rotation = randf_range(-20,20)
		vfx_text.ordering = 2
		EventHandler.create_text.emit(vfx_text)
		
	
	
	



func is_soldier(enemy: Enemy)->bool:
	
	return (enemy is GreekArcher || enemy is GreekCavalry || enemy is GreekSoldier)

func is_monster(enemy: Enemy)->bool:
	return (enemy is Chimera || enemy is Cyclops || enemy is Gorgon || enemy is Harpy)
