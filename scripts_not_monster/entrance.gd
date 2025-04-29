extends Node2D
@export_multiline var dialogue:Array[String]
@export var door:Node2D
@export var time = 1
@export var skip_after = 1.2
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	var counter = 0
	for i in dialogue:
		DialogueManager.write_and_disappear(i, time, skip_after)
		await DialogueManager.finished_text
		counter += 1
		if counter == 3:
			release_door()
	DialogueManager.disappear()

func release_door():
	var tween = create_tween()
	var dgb = door.global_position
	tween.tween_property(door, "global_position", dgb - Vector2(0,64), 1)
	pass
