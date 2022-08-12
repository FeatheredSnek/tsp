extends TextureRect

onready var start_label = $menu_cont/start
onready var info_label = $menu_cont/info
onready var options_label = $menu_cont/options
onready var exit_label = $menu_cont/exit

var current_choice = 0
var current_difficulty = 0
var menu_items = [null, null, null, null]
var disable_menu_controls = false

enum {MENU_START, MENU_INFO, MENU_OPTIONS, MENU_EXIT}


func _ready():
	PlayerVars.reset_vars()
	menu_items = [start_label, info_label, options_label, exit_label]
	menu_items[current_choice].modulate = Color.white
	$modals/modal_options.sfx_ui_accept = $sfx_ui_accept
	$modals/modal_options.sfx_ui_select = $sfx_ui_select
	$modals/modal_options.sfx_ui_back = $sfx_ui_back	
	$bgm_menu_start.stream.loop = false
	yield(get_tree(), "idle_frame")
	if not PlayerVars.music:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	$bgm_menu_start.play()
	AudioServer.set_bus_effect_enabled(1,0,false)
	OS.window_fullscreen = PlayerVars.fullscreen


func _input(event):
	if not disable_menu_controls:
		if event.is_action_pressed("ui_down"):
			cycle_menu(1)
		elif event.is_action_pressed("ui_up"):
			cycle_menu(-1)
		elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_custom_bomb"):
			$sfx_ui_back.play()
			if $modals/modal_options.visible == true:
				save_options_to_file()
				save_fullscreen_project_setting()
				$modals/modal_animations.play_backwards("options_show")
			elif $modals/modal_info.visible == true:
				$modals/modal_animations.play_backwards("info_show")
			else:
				highlight_item(MENU_EXIT)
				current_choice = MENU_EXIT
		elif event.is_action_pressed("ui_custom_fire"):
			menu_confirm_selection()
		get_tree().set_input_as_handled()


func save_options_to_file():
	var settings = ConfigFile.new()
	settings.set_value("settings", "starting_lives", PlayerVars.hp)
	settings.set_value("settings", "starting_bombs", PlayerVars.bombs)
	settings.set_value("settings", "difficulty", PlayerVars.difficulty)
	settings.set_value("settings", "music", PlayerVars.music)
	settings.set_value("settings", "fullscreen", PlayerVars.fullscreen)
	settings.save("user://settings.ini")


func save_fullscreen_project_setting():
	ProjectSettings.set_setting("display/window/size/fullscreen", PlayerVars.fullscreen)
	var err = ProjectSettings.save()


func cycle_menu(direction):
	current_choice = posmod(current_choice+direction, 4)
	for item in menu_items:
		item.modulate = Color(0.5,0.5,0.5)
	menu_items[current_choice].modulate = Color.white
	$sfx_ui_select.play()


func highlight_item(o):
	for item in menu_items:
		item.modulate = Color(0.5,0.5,0.5)
	menu_items[o].modulate = Color.white


func menu_confirm_selection():
	match current_choice:
		MENU_START:
			$modals/modal_animations.play("loading_show")
			disable_menu_controls = true
			
			# loading shaders
			$vfx_loader.cycle_shaders()
			yield($vfx_loader,"shaders_loaded")
			print("all shaders loaded")
			# loading particle effects
			$vfx_loader.cycle_effects()
			yield($vfx_loader,"effects_loaded")
			print("all particles loaded")
			
			Global.goto_scene("res://main-game-window.tscn")
			$sfx_ui_accept.play()
		MENU_INFO:
			$modals/modal_animations.play("info_show")
			$sfx_ui_accept.play()
		MENU_OPTIONS:
			$modals/modal_animations.play("options_show")
			$sfx_ui_accept.play()
		MENU_EXIT:
			get_tree().quit()



func _on_bgm_menu_start_finished():
	$bgm_menu_loop.play()



func _on_modal_options_toggle_menu_music(playing):
	if not playing:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
