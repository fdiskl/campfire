extends Node2D

@export var prefab: PackedScene
@export var min_coins: int = 3
@export var max_coins: int = 7
@export var min_distance: float = 40.0

func _ready() -> void:
	randomize()

	var markers := _get_spawn_points()
	if markers.is_empty():
		return

	var spawn_count = randi_range(min_coins, max_coins)
	spawn_count = min(spawn_count, markers.size())

	var available = markers.duplicate()
	var spawned_positions: Array[Vector2] = []

	while spawn_count > 0 and not available.is_empty():
		var index = randi() % available.size()
		var marker: Marker2D = available[index]
		available.remove_at(index)

		var pos = marker.global_position

		if _is_far_enough(pos, spawned_positions):
			_spawn_coin(pos)
			spawned_positions.append(pos)
			spawn_count -= 1


func _get_spawn_points() -> Array:
	var result: Array = []
	for child in get_children():
		if child is Marker2D:
			result.append(child)
	return result


func _is_far_enough(pos: Vector2, others: Array[Vector2]) -> bool:
	for p in others:
		if p.distance_to(pos) < min_distance:
			return false
	return true


func _spawn_coin(pos: Vector2):
	var coin = prefab.instantiate()
	add_child(coin)
	coin.global_position = pos
