extends AnimatedSprite2D


func _process(delta: float) -> void:
	if !is_playing():
		queue_free()
