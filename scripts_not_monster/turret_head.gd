extends Sprite2D
@export var initial_look:Marker2D
@export var line:Line2D

@onready var shoot_effect := $shoot_effect

func _physics_process(delta: float) -> void:
	line.set_point_position(0, global_position)
	if can_see_subject():
		if get_parent().has_voice:
			$AudioStreamPlayer2D.volume_db = -10
		look_at(can_see_subject().global_position)
		shoot_effect.visible = true
		set_attack()
		
	else:
		if $AudioStreamPlayer2D.volume_db >= -50:
			$AudioStreamPlayer2D.volume_db -= delta * 50
			
		look_at(initial_look.global_position)
		shoot_effect.visible = false
		line.set_point_position(1, global_position)

func can_see_subject():
	var direction = transform.basis_xform(Vector2.RIGHT)
	for i in range(-9,9):
		var dir = direction.rotated(deg_to_rad(i * 5))
		var space_state = get_world_2d().direct_space_state
		var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + dir * 200, 1)
		var result = space_state.intersect_ray(targ)
		if result:
			
			if result["collider"].has_method("move"):
				return result["collider"]

func set_attack():
	if can_see_subject():
		line.set_point_position(1, can_see_subject().global_position)
		can_see_subject().take_damage()
