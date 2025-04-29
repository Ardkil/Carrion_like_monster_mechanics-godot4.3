extends CharacterBody2D

@export var death_effect:Resource
@export var death_object:Resource
@export var speed:float = 30
@onready var m1 := $Marker2D
@onready var m2 := $Marker2D2
@onready var line := $lines
@onready var target_line := $Line2D
@onready var head := $head
@onready var gun := $GuardgunGgog
var target:Vector2
var aliv = true
var dir:Vector2 = Vector2(1,0)
#I forgot how to do enums
var state = 0
func _ready() -> void:
	var a = [m1,m2]
	target = a.pick_random().global_position
	new_target()
	
func attackable():
	pass

func _physics_process(delta: float) -> void:
	if aliv:
		target_line.set_point_position(0, head.global_position)
		if raycast():
			var rc = raycast()
			line.visible = false
			target_line.set_point_position(1, rc.global_position)
			state = 1
		else:
			line.visible = true
			target_line.set_point_position(1, head.global_position)
			state = 0
		velocity.y += 980 * delta
		if state == 0:
			if $AudioStreamPlayer2D.volume_db >= -50:
				$AudioStreamPlayer2D.volume_db -= delta * 50
			gun.visible = false
			if abs(global_position.x-target.x) > 10:
				var direction = target.x - global_position.x
				velocity.x = sign(direction) * speed
			else:
				velocity.x = 0
				new_target()
		if state == 1:
			$AudioStreamPlayer2D.volume_db = -10
			velocity.x = sign(raycast().global_position.x - global_position.x) * speed * 4
			gun.visible = true
			raycast().take_damage()
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
		var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + dir_ * 200, 1)
		var result = space_state.intersect_ray(targ)
		if result:
			line.get_child(i + 6).set_point_position(0, head.global_position)
			line.get_child(i + 6).set_point_position(1, result["position"])
			if result["collider"].has_method("move"):
				return result["collider"]
		else:
			line.get_child(i + 6).set_point_position(0, head.global_position)
			line.get_child(i + 6).set_point_position(1, head.global_position + dir_ * 200)
