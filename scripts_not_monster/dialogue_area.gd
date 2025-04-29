extends Area2D

@export_multiline var dialogue:Array[String]
var entered = false
@export var time:float = 1
@export var skip_after:float = 2
func _on_body_entered(body: BodyPart) -> void:
	if !entered:
		entered = true
		var counter = 0
		for i in dialogue:
			DialogueManager.write_and_disappear(i, time, skip_after)
			await DialogueManager.finished_text
		DialogueManager.disappear()
