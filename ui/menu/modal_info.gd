extends TextureRect


func _input(event):
	if visible == true:
		if event.is_action_pressed("ui_down"):
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_custom_fire"):
			get_tree().set_input_as_handled()
