extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "S (%d)" %  Globals.stop_left


	if  Globals.stop_left == 0:
		label_settings.font_color = Color("#b0b0b0")
	else:
		label_settings.font_color = Color(255,255,255,255)
