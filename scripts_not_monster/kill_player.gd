extends Area2D




func _on_body_entered(body: BodyPart) -> void:
	for i in range(1000):
		body.take_damage()
	pass # Replace with function body.
