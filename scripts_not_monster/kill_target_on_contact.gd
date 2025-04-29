extends RigidBody2D

func _ready() -> void:
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.6,1.4)

func _on_body_entered(body: Node2D) -> void:
	if linear_velocity.length() > 500:
		$AudioStreamPlayer2D.stream = load("res://sounds/hit_tentacle.mp3")
		$AudioStreamPlayer2D.play()
	if body.has_method("attackable"):
		body.destroy()
	pass # Replace with function body.
