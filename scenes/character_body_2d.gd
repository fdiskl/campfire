extends CharacterBody2D

# --- CONFIG ---
@export var jump_speed0: float = 550.0
@export var jump_speed: float = 550.0
@export var gravity: float = 980.0
@export var dialogController : Node;

var on_jump = preload("res://scenes/jump_animation.tscn");
var on_jump2 = preload("res://scenes/jump2_animation.tscn");

var on_wall = preload("res://scenes/when_you_hit_wall_animation.tscn");
var on_floot = preload("res://scenes/sideways.tscn");

@onready var sprite1 : Sprite2D = $sprite_normal;
@onready var sprite_wall : Sprite2D = $sprite_wall;


var trajectory_points: Array[Vector2] = []

var was_on_floor := false

var aiming: bool = false

var steps = 6
var TOTAL_TIME_KOOF = 0.12
var hit_val = 200

var onground_c = 0

var isfalling = false;


var is_recording = false;
var positions : Array = [];

var is_replaying = false;
var replay_idx = 0;
var replay_speed = 7000

func _process(delta: float) -> void:
	if (isfalling):
		sprite1.hide()
		sprite_wall.show()
	else:
		sprite1.show()
		sprite_wall.hide()

	sprite_wall.flip_h = velocity.x > 0


	if !is_replaying && is_on_floor() &&  !dialogController.dialog:
		update_trajectory()
	else:
		trajectory_points.clear()


func replay(delta : float) -> void:
	if positions.is_empty() || replay_idx >= positions.size():
		is_replaying = false
		return

	var trgt = positions[positions.size() - replay_idx-1]
	var dir = (trgt - position).normalized()
	var dist = (trgt - position).length()
	var step = replay_speed * delta

	if step >= dist:
		position = trgt
		replay_idx += 1
	else:
		position += dir * step

func _physics_process(delta):


	if (is_replaying):
		replay(delta)
		return


	if not is_on_floor():
		velocity.y += gravity * delta


	if (dialogController.dialog):
		velocity.x /= 3
		velocity.y = clamp(velocity.y, 100 ,10000)


	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var pos = collision.get_position()
		var normal = collision.get_normal()
		var collider = collision.get_collider()

		var rocket = false

		if collider is TileMapLayer:
			var tilemap = collider
			var local_pos = tilemap.to_local(pos)
			var cell = tilemap.local_to_map(local_pos)
			var tile_data = tilemap.get_cell_atlas_coords(cell)
			if (tile_data.x >= 0 && tile_data.x <= 2 && tile_data.y >= 0 && tile_data.y <= 2): # TODO
				rocket = true
				isfalling = true


		if normal.x > 0:
			if rocket:
				hit_val = randi_range(250, 400)

			elif isfalling:
				hit_val -= randi_range(15, 30)
			else:
				hit_val = randi_range(150, 200)
				isfalling = true
			velocity.x += hit_val
			velocity.y += randi_range(10,20)
			onground_c = 0

			var j = on_wall.instantiate()
			get_parent().add_child(j)
			j.global_position = global_position

		elif normal.x < 0:
			if rocket:
				hit_val = randi_range(250, 400)

			elif isfalling:
				hit_val -= randi_range(15, 30)
			else:
				hit_val = randi_range(150, 200)
				isfalling = true

			velocity.x -= hit_val
			velocity.y += randi_range(10,20)
			var j = on_wall.instantiate()
			get_parent().add_child(j)
			j.global_position = global_position
			j.scale.x *= -1

			onground_c = 0

		if normal.y > 0:


			if rocket:
				velocity.y += randi_range(200, 400)
				velocity.x += randi_range(-200, 200);
			else:
				velocity.y += randi_range(30, 60)
				velocity.x += randi_range(-50, 50);


			var j = on_wall.instantiate()
			get_parent().add_child(j)
			j.global_position = global_position
			j.rotation_degrees += 90
		elif normal.y < 0:

			if isfalling:

				if velocity.x > 0:
					velocity.x /= randf_range(1.05, 1.2)
					velocity.x -= randi_range(10, 20);
					velocity.x  = clamp(velocity.x, 0, 100000)
				else:
					velocity.x /= randf_range(1.05, 1.2)
					velocity.x -= randi_range(10, 20);
					velocity.x  =  clamp(velocity.x, -100000, 0)

				if velocity.x != 0:
					var j = on_floot.instantiate()
					get_parent().add_child(j)
					j.global_position = global_position

					if (velocity.x >0):
						j.scale.x *= -1


				velocity.y += randi_range(-10, -30)
				onground_c += 1

			if rocket:
				velocity.y += randi_range(-50, -70)
				var f = randf_range(0, 2)
				if f < 1:
					velocity.x += randi_range(100, 150)
				else:
					velocity.x -= randi_range(100, 150)


	move_and_slide()

	if (hit_val <= 5 || onground_c >= 5):
		isfalling = false

	var on_floor_now = is_on_floor()

	if (is_recording):
		positions.push_back(position)

	if not was_on_floor and on_floor_now and !isfalling:
		is_recording = false
		velocity.x = 0
		var j = on_jump2.instantiate()
		get_parent().add_child(j)
		j.global_position = global_position

	was_on_floor = on_floor_now



func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:

			aiming = true
		else:
			if !dialogController.dialog && aiming && is_on_floor() && !isfalling && !is_replaying:
				is_recording = true
				positions = []
				Globals.back_is_recorded = true

				velocity = compute_jump_velocity(get_global_mouse_position())
				var j = on_jump.instantiate()
				get_parent().add_child(j)
				j.global_position = global_position
				if (jump_speed >= jump_speed0) :
					jump_speed = jump_speed0

			aiming = false
			trajectory_points.clear()


	if event.is_action_pressed("b"):
		if !dialogController.dialog && !positions.is_empty() && Globals.back_left > 0 && Globals.back_is_recorded && is_on_floor() && !isfalling && !is_replaying:
			Globals.back_left -= 1
			Globals.back_is_recorded = false
			is_replaying = true;


	if event.is_action_pressed("s"):
		if !dialogController.dialog  && Globals.stop_left > 0 && !is_replaying:
			Globals.stop_left -= 1
			velocity = Vector2.ZERO;


	if event.is_action_pressed("j"):
		if !dialogController.dialog  && Globals.j_left > 0 && !is_replaying && jump_speed <= jump_speed0:
			Globals.j_left -= 1
			jump_speed = jump_speed * 2

	queue_redraw()


func compute_jump_velocity(target: Vector2) -> Vector2:
	var delta = target - global_position
	var distance = delta.length()

	# Full jump speed in that direction
	var full_vel = delta.normalized() * jump_speed

	# Compute max distance this full jump would reach
	var max_time_up = abs(full_vel.y) / gravity
	var max_distance = full_vel.x * (2 * max_time_up)  # horizontal distance

	# Scale down velocity if mouse is closer
	var factor = 1.0
	if distance < max_distance:
		factor = distance / max_distance

	return full_vel * factor

func update_trajectory():
	trajectory_points.clear()

	var start_pos = global_position
	var vel = compute_jump_velocity(get_global_mouse_position())

	# Compute max reach distance using velocity magnitude
	var max_distance = jump_speed * TOTAL_TIME_KOOF  # visual “max length” (tweak as needed)
	var target_delta = get_global_mouse_position() - global_position
	var target_distance = target_delta.length()

	# Determine how far we should draw the trajectory
	var draw_distance = min(target_distance, max_distance)

	# Scale time to match draw_distance
	# Total velocity vector length
	var vel_length = vel.length()
	if vel_length == 0:
		return  # avoid divide by zero

	var total_draw_time = draw_distance / vel_length

	# Draw trajectory points
	for i in range(steps):
		var t = (total_draw_time / (steps - 1)) * i
		var x = start_pos.x + vel.x * t
		var y = start_pos.y + vel.y * t + 0.5 * gravity * t * t
		trajectory_points.append(Vector2(x, y))

func _draw():
	if trajectory_points.size() < 2 || !is_on_floor():
		return


	for point in trajectory_points:
		draw_circle(
			to_local(point),
			1.0,                # radius of dot
			Color.WHITE            # color of dot
		)
