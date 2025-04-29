extends Node2D

@onready var body_container  := $bodies
@onready var eye := $EyeGgog
@onready var cam_follow := $cam_follow
@onready var great_tentacle := $rope
var bodies:Array[BodyPart]
var worm_joints:Array[DampedSpringJoint2D]
var main_joints:Array[DampedSpringJoint2D]
var leader:RigidBody2D


@export var great_tentacle_length:float = 50
var object:RigidBody2D
var alive = true
@export var max_hp = 30
@export var strength = 150

func _ready() -> void:
	#set worm-mainbody together
	for i in body_container.get_children():
		bodies.append(i)
		worm_joints.append(i.get_child(2))
		main_joints.append(i.get_child(3))
		
	for i in bodies:
		for j in bodies:
			if i != j:
				i.body_list.append(j)
				
	for i in range(len(worm_joints) -1):
		worm_joints[i].node_b = bodies[i + 1].get_path()
		bodies[i].draw_targets.append(bodies[i + 1])
		bodies[i].random_body_draw_target()
	
	bodies[-1].random_body_draw_target()
	bodies[-1].draw_targets.append(bodies[0])
	
	leader = bodies[len(bodies)/2]
	for i in main_joints:
		if i.get_parent() != leader:
			i.node_b = leader.get_path()
		else: print("self")
	
func distance_to_mouse(from:Vector2) -> float:
	return from.distance_to(get_global_mouse_position())

func _process(delta: float) -> void:
	if alive:
		set_leader()
func _physics_process(delta: float) -> void:
	if alive:
		eye.global_position = lerp(eye.global_position, leader.global_position, 0.4)
		set_body_target()
		great_tentacle.set_start(leader.global_position)
		great_tentacle.set_last(leader.global_position)
		
func get_closest_body() -> RigidBody2D:
	var distance = distance_to_mouse(bodies[0].global_position)
	var body = bodies[0]
	for i in bodies:
		if distance > distance_to_mouse(i.global_position):
			distance = distance_to_mouse(i.global_position)
			body = i
	return body

func set_leader():
	if get_closest_body() != leader:
		if leader:
			leader.is_leader = false
		leader = get_closest_body()
		leader.is_leader = true

func set_target_point() -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(leader.global_position, get_global_mouse_position(), 2)
	var result = space_state.intersect_ray(targ)
	if result:
		return result["position"]
	else:
		return get_global_mouse_position()

func set_body_target():
	for i in bodies:
		i.target = set_target_point()

func get_center_pos() -> Vector2:
	var vec2:Vector2 = Vector2.ZERO
	for i in bodies:
		vec2 += i.global_position
	vec2 = vec2/len(bodies)
	return vec2


func set_great_tentacle():
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(leader.global_position, get_global_mouse_position(), 4)
	var result = space_state.intersect_ray(targ)
	if result and leader.global_position.distance_to(result["position"]) < great_tentacle_length:
		object = result["collider"]
		$tentacle_hit.pitch_scale = randf_range(0.6,1.4)
		$tentacle_hit.play()
		great_tentacle.set_last(object.global_position)
		
func death():
	eye.queue_free()
	$incubate.pitch_scale = randf_range(0.6,1.4)
	$incubate.play()
	for i in bodies:
		i.explode()
	await get_tree().create_timer(1).timeout
	GameManager.respawn()

	
