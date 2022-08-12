extends Node


var position = Vector2(310,610)
var hp
var bombs
var difficulty
var score
var graze
var shadow_gauge_value
var shadow_status
var v_mult
var s_mult
var music
var fullscreen

var persistent_highscores = true

var p_item_base_score = 10000
var s_item_base_score = 100
var graze_score = 100
var graze_during_spell_bonus = 900
var bullet_item_base_score = 100
var graze_plus_v_mult = 0.01
var graze_plus_s_mult = 0.001
var starting_hp = 3
var starting_bombs = 3

var hp_penalty = 0.1
var bomb_penalty = 0.05

var s_item_base_gauge = 1000
var shadow_gauge_treshold = 100000

var stage_1_highscore

var default_hp = 3
var default_bombs = 3
var default_difficulty = DIFFICULTY_NORMAL
var default_music = true
var default_score = 0
var default_fullscreen = false

var default_s1_highscore = 100000

enum {DIFFICULTY_NORMAL, DIFFICULTY_HARD}

func _ready():
	reset_vars()
	load_settings_from_file()
	load_highscores_from_file()
	#ProjectSettings.set_setting("display/window/size/fullscreen", true)


func update_score(value):
	score += value



func reset_vars():

	var settings = ConfigFile.new()
	var err = settings.load("user://settings.ini")
	if err == OK:
		hp = settings.get_value("settings", "starting_lives", 3)
		bombs = settings.get_value("settings", "starting_bombs", 3)
	else:
		pass
	
	if not hp is int:
		hp = default_hp
	if not bombs is int:
		bombs = default_bombs
	if not difficulty is int:
		difficulty = default_difficulty
	if not music is bool:
		music = default_music
	if not fullscreen is bool:
		fullscreen = default_fullscreen
	
	score = 0
	graze = 0
	shadow_gauge_value = 0
	shadow_status = false
	v_mult = 1.00
	s_mult = 1.000
	
	############## DEBUG	
#	hp = 8
#	bombs = 8
	
	starting_hp = hp
	starting_bombs = bombs




func load_settings_from_file():
	
	var settings = ConfigFile.new()
	var err = settings.load("user://settings.ini")
	
	if err == OK:
		hp = settings.get_value("settings", "starting_lives", 3)
		bombs = settings.get_value("settings", "starting_bombs", 3)
		difficulty = settings.get_value("settings", "difficulty", 0)
		music = settings.get_value("settings", "music", true)
		fullscreen = settings.get_value("settings", "fullscreen", false)
	else:
		return



func save_highscore(stage:int):
	
	match stage:
		1:
			if score > stage_1_highscore:
				stage_1_highscore = score
	
	if persistent_highscores:
		save_highscores_to_file()



func save_highscores_to_file():
	
	var highscore_data = File.new()
	
	var highscores = {
		"stage_1" : stage_1_highscore
		}
	highscore_data.open("user://highscores.dat", File.WRITE)
	highscore_data.store_line(to_json(highscores))
	highscore_data.close()



func load_highscores_from_file():
	
	var highscore_data = File.new()
	
	if not highscore_data.file_exists("user://highscores.dat"):

		var highscores = {
			"stage_1" : 1000
			}
		highscore_data.open("user://highscores.dat", File.WRITE)
		highscore_data.store_line(to_json(highscores))
		highscore_data.close()
		stage_1_highscore = 1000

	else:
		
		highscore_data.open("user://highscores.dat", File.READ)
		var highscore_values = parse_json(highscore_data.get_line())
		if highscore_values is Dictionary and highscore_values.has("stage_1"):
			stage_1_highscore = int( highscore_values["stage_1"] )
		highscore_data.close()

	return
