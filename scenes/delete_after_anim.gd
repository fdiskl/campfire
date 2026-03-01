extends AnimatedSprite2D

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	play("default")

func _on_animation_finished() -> void:
	print("finished")
	queue_free()
