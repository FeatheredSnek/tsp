extends ColorRect

var pause_active = true
onready var continue_label = $options/continue
onready var restart_label = $options/restart
onready var exit_label = $options/exit

var current_choice = 0
var options = [null, null, null]
# 0 - continue
# 1 - restart
# 2 - exit


func _ready():
	visible = false
	options = [continue_label, restart_label, exit_label]
	for o in options:
		o.modulate = Color(0.5,0.5,0.5)
	options[current_choice].modulate = Color.white


func _input(event):
	if get_tree().paused == true:
		if event.is_action_pressed("ui_down"):
			cycle_pause_menu(1)
			pass
		elif event.is_action_pressed("ui_up"):
			cycle_pause_menu(-1)
			pass
		elif event.is_action_pressed("ui_cancel"):
			unpause()
			pass
		elif event.is_action_pressed("ui_custom_fire"):
			pause_menu_confirm_selection()
			pass
		get_tree().set_input_as_handled()



func cycle_pause_menu(direction):
	var c = current_choice + direction
	current_choice = posmod(c, 3)
	for o in options:
		o.modulate = Color(0.5,0.5,0.5)
	options[current_choice].modulate = Color.white
	$sfx_ui_select.play()



func unpause():
	visible = false
	get_tree().paused = false
	$pause_blur_background.texture = null
	$pause_blur_background.material.set_shader_param("effect_on", false)
	$sfx_ui_accept.play()



func pause_menu_confirm_selection():
	match current_choice:
		0:
			visible = false
			get_tree().paused = false
		1:
			Global.restart_game()
		2:
			Global.return_to_main_menu()
	$sfx_ui_accept.play()
