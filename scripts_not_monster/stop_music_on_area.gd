extends Area2D
var enabled = true

func _on_body_entered(body: BodyPart) -> void:
	if enabled:
		enabled = false
		AudioManager.fade_out_music()
	pass # Replace with function body.
