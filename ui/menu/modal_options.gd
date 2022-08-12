extends TextureRect

var enabled = false

var current_choice = 0
var current_difficulty
var current_lives
var current_music
var current_bombs
var current_fullscreen

var menu_items = [null, null, null, null, null]
var disable_menu_controls = false

var sfx_ui_select
var sfx_ui_accept
var sfx_ui_back

signal toggle_menu_music(playing)

func _ready():
	
	visible = false
	menu_items = [$op_difficulty, $op_lives, $op_bombs, $op_music, $op_fullscreen]
	for item in menu_items:
		item.modulate = Color(0.5,0.5,0.5)
	menu_items[current_choice].modulate = Color.white
	
	current_difficulty = PlayerVars.difficulty
	current_lives = PlayerVars.hp - 3
	current_bombs = PlayerVars.bombs - 3
	current_music = int(PlayerVars.music)
	current_fullscreen = int(PlayerVars.fullscreen)
	
	$op_lives.text = str(PlayerVars.hp)
	$op_bombs.text = str(PlayerVars.bombs)
	
	if PlayerVars.music:
		$op_music.text = "ON"
	else:
		$op_music.text = "OFF"
	
	if PlayerVars.difficulty == PlayerVars.DIFFICULTY_NORMAL:
		$op_difficulty.text = "NORMAL"
	else:
		$op_difficulty.text = "HARD"
	
	if PlayerVars.fullscreen:
		$op_fullscreen.text = "ON"
	else:
		$op_fullscreen.text = "OFF"


func _input(event):
	if visible == true:
		
		if event.is_action_pressed("ui_down"):
			cycle_menu(1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			cycle_menu(-1)
			get_tree().set_input_as_handled()
		
		match current_choice:
			0:
				if event.is_action_pressed("ui_left"):
					cycle_difficulty(-1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_right"):
					cycle_difficulty(1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_custom_fire"):
					cycle_difficulty(1)
					get_tree().set_input_as_handled()
			1:
				if event.is_action_pressed("ui_left"):
					cycle_lives(-1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_right"):
					cycle_lives(1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_custom_fire"):
					cycle_lives(1)
					get_tree().set_input_as_handled()
			2:
				if event.is_action_pressed("ui_left"):
					cycle_bombs(-1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_right"):
					cycle_bombs(1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_custom_fire"):
					cycle_bombs(1)
					get_tree().set_input_as_handled()
			3:
				if event.is_action_pressed("ui_left"):
					cycle_music(-1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_right"):
					cycle_music(1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_custom_fire"):
					cycle_music(1)
					get_tree().set_input_as_handled()
			4:
				if event.is_action_pressed("ui_left"):
					cycle_fullscreen(-1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_right"):
					cycle_fullscreen(1)
					get_tree().set_input_as_handled()
				if event.is_action_pressed("ui_custom_fire"):
					cycle_fullscreen(1)
					get_tree().set_input_as_handled()



func cycle_menu(direction):
	current_choice = posmod(current_choice+direction, 5)
	for item in menu_items:
		item.modulate = Color(0.5,0.5,0.5)
	menu_items[current_choice].modulate = Color.white
	sfx_ui_select.play()



func cycle_difficulty(direction):
	current_difficulty = posmod(current_difficulty+direction, 2)
	match current_difficulty:
		0:
			$op_difficulty.text = "NORMAL"
			PlayerVars.difficulty = PlayerVars.DIFFICULTY_NORMAL
		1: 
			$op_difficulty.text = "HARD"
			PlayerVars.difficulty = PlayerVars.DIFFICULTY_HARD
	sfx_ui_accept.play()



func cycle_lives(direction):
	current_lives = posmod(current_lives+direction, 3)
	match current_lives:
		0:
#			$op_lives.text = "3"
			PlayerVars.hp = 3
		1: 
#			$op_lives.text = "4"
			PlayerVars.hp = 4
		2: 
#			$op_lives.text = "5"
			PlayerVars.hp = 5
	$op_lives.text = str(PlayerVars.hp)
	sfx_ui_accept.play()



func cycle_bombs(direction):
	current_bombs = posmod(current_bombs+direction, 3)
	match current_bombs:
		0:
#			$op_bombs.text = "3"
			PlayerVars.bombs = 3
		1: 
#			$op_bombs.text = "4"
			PlayerVars.bombs = 4
		2: 
			PlayerVars.bombs = 5
	$op_bombs.text = str(PlayerVars.bombs)
	sfx_ui_accept.play()



func cycle_music(direction):
	current_music = posmod(current_music+direction, 2)
	match current_music:
		1:
			$op_music.text = "ON"
			PlayerVars.music = true
			emit_signal("toggle_menu_music", true)
		0: 
			$op_music.text = "OFF"
			PlayerVars.music = false
			emit_signal("toggle_menu_music", false)
	sfx_ui_accept.play()



func cycle_fullscreen(direction):
	current_fullscreen = posmod(current_fullscreen+direction, 2)
	match current_fullscreen:
		1:
			$op_fullscreen.text = "ON"
			PlayerVars.fullscreen = true
			OS.window_fullscreen = true
#			PlayerVars.save_fullscreen_setting()
		0: 
			$op_fullscreen.text = "OFF"
			PlayerVars.fullscreen = false
			OS.window_fullscreen = false
#			PlayerVars.save_fullscreen_setting()
	sfx_ui_accept.play()

