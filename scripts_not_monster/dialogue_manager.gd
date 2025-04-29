extends CanvasLayer
@onready var panel := $Panel
@onready var rtext := $Panel/RichTextLabel

signal finished_text
var writing = false
func  _ready() -> void:
	panel.visible = false
func write_and_disappear(str:String, time:float, time_between:float):
	rtext.visible_ratio = 0
	rtext.text = "[center]" + str
	panel.visible = true
	type(time,time_between)

func type(time, time_between):
	writing = true
	var tween = create_tween()
	tween.tween_property(rtext, "visible_ratio", 1, time)
	await tween.step_finished
	await get_tree().create_timer(time_between).timeout
	finished_text.emit()
	writing = false
func disappear():
	if !writing:
		panel.visible = false
