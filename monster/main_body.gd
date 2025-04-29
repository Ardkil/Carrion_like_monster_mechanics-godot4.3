extends Node2D


@onready var body_container  := $bodies
@onready var eye := $EyeGgog
@onready var cam_follow := $cam_follow
@onready var great_tentacle := $rope
@onready var camera := get_tree().current_scene.find_child("Camera2D")
var bodies:Array[BodyPart]
var worm_joints:Array[DampedSpringJoint2D]
var main_joints:Array[DampedSpringJoint2D]
var leader:RigidBody2D


@export var great_tentacle_length:float = 50
var object:RigidBody2D
var alive = true
@export var max_hp = 30
@export var strength = 150

"""
layer 3 is pickupable(bitcode 4), layer 2 is interactable like walls(bitcode 2)
"""
func _ready() -> void:
	"""
	At the starti the main body should confifure all the springs so that the body size
	can be changed at the beggining
	"""
	for i in body_container.get_children():
		bodies.append(i)
		worm_joints.append(i.get_child(2))
		main_joints.append(i.get_child(3))
		
	for i in bodies:
		for j in bodies:
			if i != j:
				i.body_list.append(j)
	
	#set joints and let all body parts know the other body parts
	for i in range(len(worm_joints) -1):
		worm_joints[i].node_b = bodies[i + 1].get_path()
		bodies[i].draw_targets.append(bodies[i + 1])
		bodies[i].random_body_draw_target()

	bodies[-1].random_body_draw_target()
	bodies[-1].draw_targets.append(bodies[0])
	
	#this will give us the middle of the now wormlike joint structre
	leader = bodies[len(bodies)/2]
	
	#set the joints that make our creature roundlike lo the moddle of the worm
	#as you may see from the body part code, the worm parts are adjusted to be wormlike every frame 
	for i in main_joints:
		if i.get_parent() != leader:
			i.node_b = leader.get_path()
		else: print("self")
	
func distance_to_mouse(from:Vector2) -> float:
	return from.distance_to(get_global_mouse_position())

func _process(delta: float) -> void:
	if alive:
		if Input.is_action_just_pressed("restart"):
			alive = false
			death()
			
		set_body_target()
		set_leader()
		camera.global_position = lerp(camera.global_position, (get_center_pos() *2 + get_global_mouse_position())/3, 0.5)
	
func _physics_process(delta: float) -> void:
	"""
	Most of the pickup logic is here
	"""
	if alive:
		#set eye position
		eye.global_position = lerp(eye.global_position, leader.global_position, 0.4)
		
		if Input.is_action_just_pressed("shoot_tentacle"):
			#Try to see if an object is available to be picked up at the input
			set_great_tentacle()
		if Input.is_action_pressed("shoot_tentacle"):
			#Object pickup and movement logic
			if object:
				great_tentacle.set_last(object.global_position - (leader.global_position - object.global_position).normalized() *2)
				if strength > object.mass:
					if leader.global_position.distance_to(object.global_position) < great_tentacle_length or leader.global_position.distance_to(get_global_mouse_position()) < great_tentacle_length:
						#Do not normalize, since we want the object to be able to gain momentum
						#so that it can be thrown
						object.linear_velocity = (get_global_mouse_position() - object.global_position) * 5
					else:
						#if the tentacle length isn't enough move it back a little
						object.linear_velocity = leader.global_position - object.global_position
			#visuals
			great_tentacle.set_start(leader.global_position)
		else:
			great_tentacle.set_start(leader.global_position)
			great_tentacle.set_last(leader.global_position)
		if Input.is_action_just_released("shoot_tentacle"):
			object = null
		
func get_closest_body() -> RigidBody2D:
	"""
	I set it up so that the closest body to the mouse would be the main body,
	this way the body will try to move to the mouse in the fastest route
	
	However a better way to do this would be to set the leader to the closest body that can
	see the mouse, if none can see the mouse you can set it like this.(this is not implemented here)
	"""
	var distance = distance_to_mouse(bodies[0].global_position)
	var body = bodies[0]
	for i in bodies:
		if distance > distance_to_mouse(i.global_position):
			distance = distance_to_mouse(i.global_position)
			body = i
	return body

func set_leader():
	"""
	sets the leader
	"""
	if get_closest_body() != leader:
		if leader:
			leader.is_leader = false
		leader = get_closest_body()
		leader.is_leader = true

func set_target_point() -> Vector2:
	"""
	sets the target position with respect to the leader body part,
	this prevents the division of the body at a sharp turn
	"""
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(leader.global_position, get_global_mouse_position(), 2)
	var result = space_state.intersect_ray(targ)
	if result:
		return result["position"]
	else:
		return get_global_mouse_position()

func set_body_target():
	"""
	updates the movement target for all the body parts
	"""
	for i in bodies:
		i.target = set_target_point()

func get_center_pos() -> Vector2:
	"""
	we need the center in order to calculate where the camera should be
	"""
	var vec2:Vector2 = Vector2.ZERO
	for i in bodies:
		vec2 += i.global_position
	vec2 = vec2/len(bodies)
	return vec2


func set_great_tentacle():
	"""
	this is the visuals for the pick up tentacle
	It also sets up the pickupable object as our object while you can see it
	"""
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

	
