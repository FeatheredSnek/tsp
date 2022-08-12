extends Node2D

var accept_input = false

func _ready():
	self.z_index = Global.CustomLayers.UI_INGAME
	yield(get_tree().create_timer(1, false),"timeout")
	accept_input = true	

func _input(event):
	if event.is_action_pressed("ui_custom_bomb") and accept_input == true:
		Global.return_to_main_menu()
		PlayerVars.reset_vars()
	if event.is_action_pressed("ui_custom_fire") and accept_input == true:
		Global.restart_game()
