extends Control

@onready var player = $player
@onready var npc = $npc

@onready var player_label = $player/Label
@onready var npc_label = $npc/Label

@onready var player_enter = $player/enter
@onready var npc_enter = $npc/enter


var typing_speed := 0.03
var current_text := ""
var current_label : Label
var typing := false
var dialog := false

var shopg := false

var idx = 0

var dialogs = [
	{
		"text": "I found some...",
		"is_player": true,
		"shop": false,
	},
	{
		"text": "Let's see if we can make a deal.",
		"is_player": false,
		"shop": false,
	},
	{
		"text" : "You give me ALL your crystalls, \n i give you some stuff",

		"is_player": false,
		"shop": true,	}
]

func show_dialog(text: String, is_player: bool, shop : bool):
	if shop:
		shopg = true
	dialog = true
	# Hide both first
	player.visible = false
	npc.visible = false
	
	# Choose who speaks
	if is_player:
		player.visible = true
		player_enter.visible = false
		current_label = player_label
	else:
		npc.visible = true
		npc_enter.visible = false
		current_label = npc_label
	
	current_text = text
	current_label.text = ""
	current_label.label_settings.font_size = 1
	
	start_typewriter()
	
func start_typewriter():
	typing = true
	
	for i in current_text.length():
		current_label.text += current_text[i]
		await get_tree().create_timer(typing_speed).timeout
	
	typing = false
	player_enter.visible = true
	npc_enter.visible = true
	
func open_shop():
	var v = Globals.coins % randi_range(1,3)
	if Globals.coins != 0 && v == 0:
		v += 1
	print(Globals.back_left, " ", v )
	Globals.back_left += v
	Globals.coins = 0
	dialog = false
	player.visible = false
	npc.visible = false
	
func _next():
	if (shopg):
		open_shop()
	if (idx >= dialogs.size()):
		return
	var d = dialogs[idx]
	show_dialog(d["text"], d["is_player"], d["shop"])
	idx +=1
	
func _input(event) -> void:	
	if event.is_action_pressed("ui_accept") && !typing:
		_next()
