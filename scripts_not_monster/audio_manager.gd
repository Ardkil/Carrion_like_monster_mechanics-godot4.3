extends AudioStreamPlayer2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("settings"):
		$CanvasLayer.visible = !$CanvasLayer.visible


func _on_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_db(sfx_index, value)
	pass # Replace with function body.


func _on_h_slider_2_value_changed(value: float) -> void:
	var mi= AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(mi, value)
	pass # Replace with function body.

func fade_out_music():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -50, 3)
