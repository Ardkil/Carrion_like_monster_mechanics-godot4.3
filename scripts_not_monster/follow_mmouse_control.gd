extends TextureRect


func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - Vector2(8,8)
