extends Area2D
@export var suicide_guards:Resource
var enabled = true


func _on_body_entered(body: BodyPart) -> void:
	if enabled:
		enabled = false
		var s = suicide_guards.instantiate()
		get_tree().current_scene.call_deferred("add_child", s)
	pass # Replace with function body.
