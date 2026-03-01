extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Press B to go back (%d left)" %  Globals.back_left
	
	
	if !Globals.back_is_recorded || Globals.back_left == 0:
		label_settings.font_color = Color("#2d2d2d")
	else:
		label_settings.font_color = Color(255,255,255,255)
		
	
