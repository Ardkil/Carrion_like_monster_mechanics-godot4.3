extends Node2D
@export var death_effect:Resource
@export var death_object:Resource
var aliv = true
func attackable():
	pass

func destroy():
	if aliv:
		aliv = false
		var d_e = death_effect.instantiate()
		d_e.global_position = global_position
		get_tree().current_scene.add_child(d_e)
		
		var d_o = death_object.instantiate()
		d_o.global_position = global_position
		d_o.global_rotation = global_rotation
		get_tree().current_scene.call_deferred("add_child", d_o)
		get_parent().call_deferred("queue_free")
