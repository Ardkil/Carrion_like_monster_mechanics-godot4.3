extends Node2D
func _ready() -> void:
	for c in get_children():
		c.set_point_position(0, global_position)
		c.set_point_position(1, global_position)
	await  get_tree().create_timer(1).timeout
	send()
	
@export var tentacles:int = 10
func send():
	var results = []
	for i in range(tentacles):
		var shoot_dir = Vector2.RIGHT.rotated(deg_to_rad(i * 360/tentacles)) * 300
		var space_state = get_world_2d().direct_space_state
		var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + shoot_dir, 2)
		var result = space_state.intersect_ray(targ)
		if result:
			results.append(result["position"])
	if results:
		var counter = 0
		for i in results:
			get_child(counter).set_point_position(0, get_parent().global_position)
			get_child(counter).set_point_position(1, i)
			counter += 1
		
