extends CharacterBody2D

@export var death_effect:Resource
@export var death_object:Resource
@export var speed:float = 30
@onready var m1 := $Marker2D
@onready var m2 := $Marker2D2
@onready var target_line := $Line2D
@onready var head := $head
@onready var gun := $GuardgunGgog
var target:Vector2
var aliv = true
var dir:Vector2 = Vector2(1,0)
var ready_ = false
#I forgot how to do enums
var state = 0
	
	
func attackable():
	pass

func _physics_process(delta: float) -> void:
	if aliv:
		velocity.x = speed * 4
		target_line.set_point_position(0, head.global_position)
		velocity.y += 980 * delta
		var rc = raycast()
		if rc:
			target_line.set_point_position(1, rc.global_position)
			velocity.x = sign(raycast().global_position.x - global_position.x) * speed * 4
			gun.visible = true
			rc.take_damage()
		else:
			target_line.set_point_position(1, head.global_position)
		move_and_slide()
		
func new_target():
	if target == m1.global_position:
		$AnimatedSprite2D.flip_h = true
		target = m2.global_position
		dir = Vector2(-1,0)
	else:
		$AnimatedSprite2D.flip_h = false
		target = m1.global_position
		dir = Vector2(1,0)
func destroy():
	if aliv:
		aliv = false
		var d_e = death_effect.instantiate()
		d_e.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", d_e)
		
		var d_o = death_object.instantiate()
		d_o.global_position = global_position
		d_o.global_rotation = global_rotation
		get_tree().current_scene.call_deferred("add_child", d_o)
		queue_free()

func raycast():
	for i in range(-6,6):
		var dir_ = dir.rotated(deg_to_rad(i * 5))
		var space_state = get_world_2d().direct_space_state
		var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + dir_ * 500, 1)
		var result = space_state.intersect_ray(targ)
		if result:
			if result["collider"].has_method("move"):
				return result["collider"]
