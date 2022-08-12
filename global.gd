extends Node

var loader
var wait_frames
var current_scene
var pause_disabled = false

var current_game_viewport = null

enum CustomLayers {
	RENDERED_BACKGROUND, 
	BOSS_BACKGROUND,
	BOSS_SEAL,
	PLAYER_SEAL,
	PLAYER_BULLET,
	PLAYER_SPRITE,
	ENEMY_SPRITE,
	PLAYER_HITBOX,
	ITEMS,
	BULLETS,
	VFX,
	UI_INGAME
	}


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	wait_frames = 120


func goto_scene(path):
	current_scene = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		return
	set_process(true)


func _process(_time):
	if loader == null:
		set_process(false)
		return
	if wait_frames > 0:
		wait_frames -= 1
		return
	var err = loader.poll()
	if err == ERR_FILE_EOF:
		var resource = loader.get_resource()
		loader = null
		set_new_scene(resource)
		return


func set_new_scene(scene_resource):
	current_scene.queue_free()
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)

#
#func restart_current_scene():
#	var root = get_tree().get_root()
#	current_scene = root.get_child(root.get_child_count() - 1)
#	var path = current_scene.get_path()
#	var reloaded = load(str(path))
#	current_scene.queue_free()
#	get_node("/root").add_child(reloaded.instance())


func restart_game():
	current_scene = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
	var game_scene = load("res://main-game-window.tscn")
	current_scene.queue_free()
	get_tree().paused = false
	PlayerVars.reset_vars()
	yield(get_tree(),"idle_frame")
	get_node("/root").add_child(game_scene.instance())
	


func return_to_main_menu():
	current_scene = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
	var menu_scene = load("res://ui/menu/main_menu.tscn")
	current_scene.queue_free()
	current_game_viewport = null
	yield(get_tree(),"idle_frame")
	get_node("/root").add_child(menu_scene.instance())
	get_tree().paused = false
