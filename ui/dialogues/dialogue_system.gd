extends Node2D

var currentschema
var windows = [null, null]
var dialogue_step
var dialogue_active
var start_from_top
var framecounter = 0

signal dialogue_finished


func _physics_process(delta):
	cycle_skip()


func cycle_skip():
	framecounter += 1
	if Input.is_action_pressed("ui_custom_skip") and framecounter % 10 == 0 and dialogue_active:
		cycle_dialogue()


func _ready():
	$dialogue_window_top.visible = false
	$dialogue_window_bot.visible = false
	$dialogue_window_top.modulate = Color.transparent
	$dialogue_window_bot.modulate = Color.transparent
	$dialogue_window_top.rect_position.x = 570
	$dialogue_window_bot.rect_position.x = -560
	z_index = Global.CustomLayers.UI_INGAME


func init_dialogue(schema):
	currentschema = schema
	if currentschema.schemadata[0].pos == "top":
		start_from_top = true
		windows[0] = $dialogue_window_top
		windows[1] = $dialogue_window_bot
	elif currentschema[0].pos == "bot":
		start_from_top = false
		windows[0] = $dialogue_window_bot
		windows[1] = $dialogue_window_top
	windows[0].get_child(0).modulate = Color.gray
	windows[0].get_child(1).modulate = Color.gray
	windows[1].get_child(0).modulate = Color.gray
	windows[1].get_child(1).modulate = Color.gray
	show_first_window()



func show_first_window():
	
	windows[0].get_child(0).modulate = Color.white
	windows[0].get_child(1).modulate = Color.white
	windows[0].get_child(1).texture = currentschema.schemadata[0].img
	windows[0].get_child(0).text = currentschema.schemadata[0].txt
	windows[0].visible = true
	
	if start_from_top:
		$animations_movement.play("show_top")
	else:
		$animations_movement.play("show_bottom")
	
	$dialogue_sound.play()
	
	dialogue_step = 1
	yield(get_tree().create_timer(0.5, false), "timeout")
	dialogue_active = true



func show_second_window():

	$modulate_tween.interpolate_property(windows[0].get_child(0), "modulate", Color.white, Color.gray, 0.1, Tween.TRANS_LINEAR)
	$modulate_tween.interpolate_property(windows[0].get_child(1), "modulate", Color.white, Color.gray, 0.1, Tween.TRANS_LINEAR)
	$modulate_tween.start()

	windows[1].get_child(1).texture = currentschema.schemadata[1].img
	windows[1].get_child(0).text = currentschema.schemadata[1].txt
	windows[1].get_child(0).modulate = Color.white
	windows[1].get_child(1).modulate = Color.white
	windows[1].visible = true
	
	if start_from_top:
		$animations_movement.play("show_bottom")
	else:
		$animations_movement.play("show_top")
	
	$dialogue_sound.play()
	
	dialogue_step = 2



func end_dialogue():
	dialogue_active = false
	$animations_movement.play("hide_all")
	yield($animations_movement, "animation_finished")
	emit_signal("dialogue_finished")
	queue_free()



func cycle_dialogue():
	if dialogue_step == currentschema.schemadata.size():
		end_dialogue()
		pass
	else:
		if dialogue_step == 1:
			show_second_window()
		elif dialogue_step > 1:
			# current window fade out
			$modulate_tween.interpolate_property(windows[1].get_child(0), "modulate", Color.white, Color.gray, 0.1, Tween.TRANS_LINEAR)
			$modulate_tween.interpolate_property(windows[1].get_child(1), "modulate", Color.white, Color.gray, 0.1, Tween.TRANS_LINEAR)
			$modulate_tween.start()
			# next window load data and fade in
			windows[0].get_child(1).texture = currentschema.schemadata[dialogue_step].img
			windows[0].get_child(0).text = currentschema.schemadata[dialogue_step].txt
			$modulate_tween.interpolate_property(windows[0].get_child(0), "modulate", Color.gray, Color.white, 0.1, Tween.TRANS_LINEAR)
			$modulate_tween.interpolate_property(windows[0].get_child(1), "modulate", Color.gray, Color.white, 0.1, Tween.TRANS_LINEAR)
			$modulate_tween.start()
			# reverse windows
			windows.invert()
			dialogue_step += 1
			
			$dialogue_sound.play()
			
		pass



func _input(event):
	if dialogue_active == true:
		if event.is_action_pressed("ui_custom_fire"):
			get_tree().set_input_as_handled()
			cycle_dialogue()
		if event.is_action_pressed("ui_custom_bomb"):
			get_tree().set_input_as_handled()
			end_dialogue()
