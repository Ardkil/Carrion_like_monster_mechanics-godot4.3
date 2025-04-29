extends Area2D
class_name SpawnPoint

var body = preload("res://monster/main_body.tscn")
var body_part = preload("res://monster/body_part.tscn")
var greater_bp = preload("res://monster/body_part_greater.tscn")
@export var size = 0
@export var max_hp = 30
@export var strength = 150
@export var is_alpha = false
var incubateable = false
var body_

func _on_body_entered(body: BodyPart) -> void:
	incubateable = true
	GameManager.set_respawn(global_position, self)
	body_ = body
	activate()
	$RichTextLabel.visible = true

func activate():
	$AnimatedSprite2D.play("activated")
	pass

func deactivate():
	$AnimatedSprite2D.play("default")

func respawn():
	var b = body.instantiate()
	b.global_position = global_position
	for i in range(size):
		print(i)
		var bp
		if is_alpha:
			bp = greater_bp.instantiate()
		else: 
			bp = body_part.instantiate()
		b.get_child(0).add_child(bp)
	b.max_hp = max_hp
	print(b.get_child(0).get_child_count())
	b.strength = strength
	get_tree().current_scene.add_child(b)
	

func _process(delta: float) -> void:
	if incubateable and Input.is_action_just_pressed("incubate") and body_.get_parent().get_parent().alive:
		body_.get_parent().get_parent().alive = false
		body_.get_parent().get_parent().death()
		incubateable = false

func _on_body_exited(body: BodyPart) -> void:
	body_ = null
	incubateable = false
	$RichTextLabel.visible = false
	pass # Replace with function body.
