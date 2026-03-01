extends Camera2D

@export var player : CharacterBody2D
const OFFSET = -70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y = player.position.y + OFFSET
