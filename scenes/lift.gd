extends Node2D

@onready var area = $Area2D

func _ready() -> void:
	area.area_entered.connect(_on_area_entered);
	
func _on_area_entered() -> void:
	pass
