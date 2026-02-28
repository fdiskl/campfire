extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var player : CharacterBody2D = $CharacterBody2D

var  WIDTH = 8
var HEIGHT = 6
const ROOM_TILE_WIDTH = 10   # width of a room in tiles
const ROOM_TILE_HEIGHT = 8  # height of a room in tiles
const CELL_SIZE = 16

var map := []


func _ready() -> void:
	generatePath()
	pad_map()
	placeExtraRooms()
	draw_map()

func generatePath() -> void:
	# S: start
	# 0: fill
	# 1: left, right
	# 2: left, right, bottom
	# 3: left, right, top
	# 4: left, right, top, bottom
	# 7: pit top
	# 8: pit center
	# 9: pit bottom
	# E: end

	for y in range(HEIGHT):
		map.append([])
		for x in range(WIDTH):
			map[y].append("0")

	var posX : int = 0
	var posY : int = 0

	# random start position
	var startPosition = randi_range(0, WIDTH - 1)
	map[0][startPosition] = "S"
	posX = startPosition

	var movedOnce : bool = false
	var finished : bool = false

	while !finished:
		# first move
		if !movedOnce:
			if posX > 0 && posX < WIDTH - 1:
				var nextRoom = randi_range(1, 2)
				if nextRoom == 1:
					posX -= 1
				else:
					posX += 1
			elif posX == 0:
				posX += 1
			elif posX == WIDTH - 1:
				posX -= 1  # fix corner case

			map[posY][posX] = "1"
			movedOnce = true

		# second and later moves
		elif movedOnce && posY < HEIGHT - 1:
			if posX == 0 || posX == WIDTH - 1:
				if posY > 0 && (map[posY - 1][posX] == "2" || map[posY - 1][posX] == "4"):
					map[posY][posX] = "4"
				else:
					map[posY][posX] = "2"

				posY += 1
				if posY >= HEIGHT:
					posY = HEIGHT - 1
				map[posY][posX] = "3"
				movedOnce = false
			else:
				var way = randi_range(1, 2)
				if way == 1:
					if posX > 0 && map[posY][posX - 1] == "0":
						posX -= 1
						map[posY][posX] = "1"
					elif posX < WIDTH - 1:
						posX += 1
						map[posY][posX] = "1"
				else:
					if posY > 0 && (map[posY - 1][posX] == "2" || map[posY - 1][posX] == "4"):
						map[posY][posX] = "4"
					else:
						map[posY][posX] = "2"

					posY += 1
					if posY >= HEIGHT:
						posY = HEIGHT - 1
					map[posY][posX] = "3"
					movedOnce = false

		# last step
		else:
			if posX > 0 && posX < WIDTH - 1:
				var nextRoom = randi_range(1, 2)
				if nextRoom == 1:
					posX -= 1
				else:
					posX += 1

				map[posY][posX] = "1"
			else:
				map[posY][posX] = "E"
				finished = true


func placeExtraRooms():

	#randi_range fill
	for y in HEIGHT:
		for x in WIDTH:
			if map[y][x] == "0":
				var fillRooms = randi_range(1,10)
				if fillRooms <= 3:
					match fillRooms:
						1:
							map[y][x] = "1"
						2:
							if y < 4 && y  < HEIGHT - 2:
								if map[y+1][x] == "2":
									map[y][x] = "2"
									map[y+1][x] = "4"
							else:
								map[y][x] = "2"
						3:
							if y > 0:
								if map[y-1][x] == "3":
									map[y][x] = "3"
									map[y-1][x] = "4"
							else:
								map[y][x] = "3"




func pad_map(padding: int = 4) -> void:
	var oldH = HEIGHT
	var oldW = WIDTH
	HEIGHT += padding * 2
	WIDTH += padding * 2

	var new_map := []

	# Fill new_map with "0"
	for y in range(HEIGHT):
		new_map.append([])
		for x in range(WIDTH):
			new_map[y].append("0")

	# Copy old map into center
	for y in range(oldH):
		for x in range(oldW):
			new_map[y + padding][x + padding] = map[y][x]

	map = new_map

func draw_map():
	tilemap.clear()

	for y in range(HEIGHT):
		for x in range(WIDTH):
			var room_type = map[y][x]
			var layout = getRoomLayout(room_type)

			if room_type == 'S':
				player.position.x = x * ROOM_TILE_WIDTH * CELL_SIZE;
				player.position.y = y * ROOM_TILE_HEIGHT * CELL_SIZE;

			for ry in range(ROOM_TILE_HEIGHT):
				for rx in range(ROOM_TILE_WIDTH):
					var tile_id = layout[ry][rx]
					if tile_id != 0:
						tilemap.set_cell(
							Vector2i(x * ROOM_TILE_WIDTH + rx,
							y * ROOM_TILE_HEIGHT + ry),
							0,
							Vector2i(0,0),
						)


	# S: start
	# 0: fill
	# 1: left, right
	# 2: left, right, bottom
	# 3: left, right, top
	# 4: left, right, top, bottom
	# 7: pit top
	# 8: pit center
	# 9: pit bottom
	# E: end
func getRoomLayout(c : String ) -> Array :
	match c:
		'S':
			return testStartRoom
		'0':
			return testFillRoom

		'1':
			return testLRRoom

		'2':
			return testLRBRoom

		'3':
			return testLRTRoom

		'4':
			return testLRTBRoom

		'E':
			return testEndRoom


	return testEmptyRoom


var testEmptyRoom = [
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
]

var testLRTBRoom = [
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0,0,1],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
]

var testLRTRoom = [
	[0,0,0,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1],
]


var testLRBRoom = [
	[1,1,1,1,1,1,1,1,1,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
]


var testLRRoom = [
	[1,1,1,1,1,1,1,1,1,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1],
]

var testFillRoom = [
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1,1,1,1],
]


var testStartRoom = [
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1],
]



var testEndRoom = [
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1,1,1,1],
]


var mining = false
var mining_tile : Vector2i
var mining_progress = 0.0
var mining_time = 0.8 # how long to fully mine
var max_range = 16 * 5

@onready var overlay = $MiningOverlay

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start mining
				var mouse_pos = tilemap.get_global_mouse_position()
				if !can_mine(mouse_pos):
					return
				mining = true
				mining_tile = get_tile_at_mouse(mouse_pos)
				mining_progress = 0.0
				overlay.visible = true
				update_overlay()
			else:
				# Stop mining
				mining = false
				mining_progress = 0.0
				overlay.visible = false

func _process(delta):
	if mining:
		var mouse_pos = tilemap.get_global_mouse_position()
		if !can_mine(mouse_pos):
			overlay.visible = false
			return
		overlay.visible = true
		

		var current_tile = get_tile_at_mouse(mouse_pos)
		if current_tile != mining_tile:
			# switched tile
			mining_tile = current_tile
			mining_progress = 0.0

		mining_progress += delta
		update_overlay()

		if mining_progress >= mining_time:
			mine_tile(mining_tile)
			mining_progress = 0.0
			overlay.visible = false

func update_overlay():
	# Move overlay above tile
	
	overlay.global_position = Vector2(mining_tile.x * CELL_SIZE + CELL_SIZE/2,
									  mining_tile.y * CELL_SIZE + CELL_SIZE/2)
	# Update animation frame (0-9)
	# var stage = int((mining_progress / mining_time) * 9)
	# stage = clamp(stage, 0, 9)
	# overlay.frame = stage

func get_tile_at_mouse(mouse_pos : Vector2) -> Vector2i:
	return Vector2i(mouse_pos.x / CELL_SIZE, mouse_pos.y / CELL_SIZE)

func can_mine(mouse_pos : Vector2) -> bool:
	return player.position.distance_to(mouse_pos) <= max_range

func mine_tile(tile: Vector2i) -> void:
	if tilemap.get_cell_atlas_coords(tile) == Vector2i(0,0):
		tilemap.set_cell(tile, 0, Vector2i(4,3))
