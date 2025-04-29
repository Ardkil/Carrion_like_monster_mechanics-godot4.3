extends BodyPart

func  _process(delta: float) -> void:
	timer -= delta
	damage_timer -= delta
	attack_timer -= delta
	
	#ensure that you can be flat
	set_worm_joints()
	draw_body_connectors()
	if global_position.distance_to(tentacle_move_target_position) > tentacle_length or !can_see_tentacle():
		shoot_movement_tentacles()
	
	attack_line.set_point_position(0, global_position)
	if attack_timer < 0:
		attack_line.set_point_position(1, global_position)
	
func _on_body_entered(body: Node) -> void:
	if body.has_method("attackable"):
		body.destroy()
	pass # Replace with function body.
