extends Area2D

var enabled = true
func _on_body_entered(body: BodyPart) -> void:
	if enabled:
		enabled = false
		get_tree().change_scene_to_file("res://other scenes/end.tscn")	
