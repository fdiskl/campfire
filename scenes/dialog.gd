extends Control

@onready var player = $player
@onready var npc = $npc

@onready var player_label = $player/Label
@onready var npc_label = $npc/Label

@onready var player_enter = $player/enter
@onready var npc_enter = $npc/enter


@onready var audioPlayer = $player/audio
@onready var audioNpc = $npc/audio2


var typing_speed := 0.03
var current_text := ""
var current_label : Label
var typing := false
var dialog := false

var shopg := false

var idx = 0

func get_dialog(coins):
	return [
		{
			"text": "I found some..." if coins != 0 else "I didn't :(",
			"is_player": true,
			"shop": false,
		},
		{
			"text": "Let's see if we can make a deal." if coins != 0 else "How could you possibly not collect \n even a single one",
			"is_player": false,
			"shop": false,
		},
		{
			"text" : "You give me ALL your crystalls, \n i give you some stuff"  if coins != 0 else "I will let you go further this time",

			"is_player": false,
			"shop": false,	},
		{
			"text" : "Also it's the only way to this door, \n so I think we have a deal"  if coins != 0 else "But you are not getting any bonuses",

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
		audioPlayer.play()
		player.visible = true
		player_enter.visible = false
		current_label = player_label
	else:
		audioNpc.play()
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

	audioNpc.stop()
	audioPlayer.stop()

func open_shop():
	if Globals.coins == 0:
		Globals.coins = 0
		dialog = false
		player.visible = false
		npc.visible = false
		Globals.level+=1
		if Globals.level <= Globals.levels.size() - 1:
			get_tree().change_scene_to_file("res://scenes/%s.tscn" % Globals.levels[Globals.level] )
		else:
			pass # TODO: you won

	var total = Globals.coins
	var r1 = randf()
	var r2 = randf()
	var r3 = randf()
	var sum_r = r1 + r2 + r3

	var add_back = abs(round(r1 / sum_r * total))
	var add_stop = abs(round(r2 / sum_r * total))
	var add_j = abs(total - add_back - add_stop)

	Globals.back_left += add_back
	Globals.stop_left += add_stop
	Globals.j_left += add_j

	Globals.coins = 0
	dialog = false
	player.visible = false
	npc.visible = false
	Globals.level+=1
	if Globals.level <= Globals.levels.size() - 1:
		get_tree().change_scene_to_file("res://scenes/%s.tscn" % Globals.levels[Globals.level] )
	else:
		pass # TODO: you won

func _next():
	if (shopg):
		open_shop()
	var dialogs = get_dialog(Globals.coins)
	if (idx >= dialogs.size()):
		return
	var d = dialogs[idx]
	show_dialog(d["text"], d["is_player"], d["shop"])
	idx +=1

func _input(event) -> void:
	if event.is_action_pressed("ui_accept") && !typing:
		_next()
