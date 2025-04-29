extends Node

var respawn_point:Vector2
var spawn_thing:SpawnPoint

func set_respawn(to:Vector2, spawn:SpawnPoint):
	respawn_point = to
	if spawn_thing:
		spawn_thing.deactivate()
	spawn_thing = spawn


func respawn():
	if spawn_thing:
		spawn_thing.respawn()
