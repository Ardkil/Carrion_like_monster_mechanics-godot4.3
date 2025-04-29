extends RigidBody2D
class_name BodyPart
var is_leader = false
var target:Vector2 = Vector2.ZERO
var body_list:Array[BodyPart]
var draw_targets:Array[BodyPart]
@onready var line1 := $Line2D
@onready var line2 := $Line2D2
@onready var tentacle_line := $Line2D3
@onready var attack_line := $attack

@export var force:float = 0.2
@export var limit_vel:float = 200
@export var tentacle_length:float = 100
@export var attack_tentacle_length:float = 150
var tentacle_move_target_position:Vector2
var timer = 0.2
var attack_timer = 0

"""
layer 3 is pickupable(bitcode 4), layer 2 is interactable like walls(bitcode 2)
"""
func _ready() -> void:
	target = global_position
	shoot_movement_tentacles()
	
func  _process(delta: float) -> void:
	timer -= delta
	damage_timer -= delta
	attack_timer -= delta
	
	set_worm_joints()
	draw_body_connectors()
	
	if global_position.distance_to(tentacle_move_target_position) > tentacle_length or !can_see_tentacle():
		#reshoot tentacles
		shoot_movement_tentacles()
	
	attack_line.set_point_position(0, global_position)
	if attack_timer < 0:
		attack_line.set_point_position(1, global_position)
	
	if Input.is_action_just_pressed("shoot_tentacle"):
		#This is not pickup logic, but it is attacking while very close logic
		var target_attack = send_attack_tentacle()
		if target_attack:
			attack_timer = 1.2
			sent_attack_tentacle_draw(target_attack.global_position, target_attack)
			
func _physics_process(delta: float) -> void:
	if (is_leader or can_see_target()) and Input.is_action_pressed("move"):
		#you can only move independantly if you are the leader or can see the target
		move(delta)
	if !Input.is_action_pressed("move") and timer < 0:
		#Friction should be set to normal while not moving
		physics_material_override.friction = 1
		#apply central force from the tentacles to the body parts
		#Do not normalize since we want more pull if the tentacle is longer
		#Otherwise you wouldn't be able to hang on the air and would be directly pulled towards
		#the direction with more tentacles
		apply_central_force((tentacle_move_target_position - global_position) * 15)
	else:
		#Friction should be negligible during movement, this is so that we can slide in easier
		#in small crevices
		physics_material_override.friction = 0
		
		
func move(delta):
	"""
	Movement logic for body part that can move independantly
	Do not directly set the linear velocity since  that will deactivate spring physics
	I did not apply the force directly since this returned extremly wobbly and unstable results
	"""
	var weighted_dir = target - global_position
	if weighted_dir.length() > 5:
		linear_velocity += weighted_dir.normalized() * 1500 * delta
	else:
		linear_velocity = Vector2.ZERO
	if linear_velocity.length() > limit_vel:
		linear_velocity = linear_velocity.normalized() * limit_vel


func can_see_target() -> bool:
	"""
	the target is set up at the main body, this is to see if this body part should be able to move independantly
	"""
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(global_position, target + (global_position - target).normalized(), 2)
	var result = space_state.intersect_ray(targ)
	if result:
		return false
	else:
		return true

func get_closest_body() -> BodyPart:
	"""
	returns the closest body that is not itself
	"""
	var distance = global_position.distance_to(body_list[0].global_position)
	var body = body_list[0]
	for i in body_list:
		if distance > global_position.distance_to(i.global_position):
			distance = global_position.distance_to(i.global_position)
			body = i
	return body

func set_worm_joints():
	"""
	While trying to fit into small spaces, the worm like structre we build in the main body
	might get stuck in different shapes, so instead we make the worm like structre to be flexible
	by connecting the joints to the closest body part to this body part
	this way while trying to fit into small spaces, we will stretch and readjust the worm
	"""
	$Worm.node_b = get_closest_body().get_path()

func random_body_draw_target():
	draw_targets.append(body_list.pick_random())

func draw_body_connectors():
	"""
	simply draw the veins so that the creature looks whole
	"""
	if draw_targets:
		line1.set_point_position(0, global_position)
		line1.set_point_position(1, draw_targets[0].global_position)
		line2.set_point_position(0, global_position)
		line2.set_point_position(1, draw_targets[1].global_position)
		tentacle_line.set_point_position(0, global_position)
		
func shoot_movement_tentacles():
	"""draws random tentacles in a 360 degree direction,
	a better way to do this would be to make it a certain angle with the mouse position
	but this looked egood enough so i left it as is
	"""
	var results = []
	for i in range(36):
		var shoot_dir = Vector2.RIGHT.rotated(deg_to_rad(i * 10)) * tentacle_length
		var space_state = get_world_2d().direct_space_state
		var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + shoot_dir, 2)
		var result = space_state.intersect_ray(targ)
		if result:
			results.append(result["position"])
	if results:
		sent_tentacle(results.pick_random())
		await get_tree().create_timer(0.5).timeout

func can_see_tentacle() -> bool:
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(global_position, tentacle_move_target_position + (global_position - tentacle_move_target_position).normalized(), 2)
	var result = space_state.intersect_ray(targ)
	if result:
		return false
	else:
		return true

func sent_tentacle(result:Vector2):
	"""
	smoothly interpolates the tentacle limbs from previous target to new target
	"""
	var tween = create_tween()
	tween.tween_method(func funct(value):tentacle_line.set_point_position(1,value), tentacle_move_target_position, global_position, 0.1)
	tentacle_move_target_position = result
	$squish.pitch_scale = randf_range(0.6,1.4)
	$squish.play()
	tween.tween_method(func funct(value):tentacle_line.set_point_position(1,value), global_position,tentacle_move_target_position, 0.1)
	
func sent_attack_tentacle_draw(result:Vector2, ta):
	"""
	draws attack lines
	"""
	var tween = create_tween()
	tween.tween_method(func funct(value):attack_line.set_point_position(1,value), global_position,result, 0.1)
	await tween.step_finished
	$tentacle_hit.pitch_scale = randf_range(0.6,1.4)
	$tentacle_hit.play()
	ta.destroy()
	tween.tween_method(func funct(value):attack_line.set_point_position(1,value), result, result, 1)
	await tween.step_finished
	tween.tween_method(func funct(value):attack_line.set_point_position(1,value), result, global_position, 0.1)
	await tween.step_finished

var damage_timer = 0.2
var blood = preload("res://effects/blood.tscn")
func take_damage():
	
	#kill main_body, i was too lazy for signals
	if get_parent().get_parent().alive:
		get_parent().get_parent().max_hp -= 1
		if get_parent().get_parent().max_hp < 0:
			get_parent().get_parent().alive = false
			get_parent().get_parent().death()
		
		
	if damage_timer < 0:
		var b = blood.instantiate()
		b.global_position = global_position
		get_tree().current_scene.add_child(b)
		damage_timer = 0.2

func send_attack_tentacle():
	"""
	attack while close
	"""
	var space_state = get_world_2d().direct_space_state
	var targ = PhysicsRayQueryParameters2D.create(global_position, global_position + (get_global_mouse_position() - global_position).normalized() * attack_tentacle_length, 2)
	var result = space_state.intersect_ray(targ)
	if result and result["collider"].has_method("attackable"):
		return result["collider"]
		
var explosion = preload("res://effects/death_explosion.tscn")
func explode():
	var e = explosion.instantiate()
	e.global_position = global_position
	get_tree().current_scene.add_child(e)
	queue_free()
