extends AnimatedSprite2D

func _ready() -> void:
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)
	play("default")

func _on_animation_finished() -> void:
	queue_free()
