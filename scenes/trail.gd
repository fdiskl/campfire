extends Line2D

var prev = Vector2.ZERO
var rad = 0.0

func _ready():
	var sprite = get_parent()
	if sprite.texture:
		rad = sprite.texture.get_size().x * 0.5
	
	prev = sprite.global_position

func _process(delta: float) -> void:
	var curr = get_parent().global_position
	var delta_pos = curr - prev

	if delta_pos.length() > 0.001:
		var dir = delta_pos.normalized()
		add_point(curr - rad * dir)
		add_point(to_local(curr))

		if points.size() > 30:
			remove_point(0)

	prev = curr
