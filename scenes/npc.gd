extends Area2D

@export var dialogController : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(b : Node2D) -> void:
	if !dialogController.dialog && dialogController.idx == 0:
		dialogController.show_dialog("I hope you found some crystals for me", false, false)
