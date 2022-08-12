extends Node2D

func _ready():
	Global.current_game_viewport = $game_viewport_container/game_viewport
	Global.pause_disabled = true
	PlayerVars.reset_vars()
	modulate = Color.black
	$init_animation.play("start")
	yield($init_animation, "animation_finished")
	Global.pause_disabled = false
	$pause_menu.visible = false


func _process(_delta):
	$debug.text = get_node("game_viewport_container/3d_background_viewport/bg_midlane/camera_animation").current_animation
	pass


func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused and not Global.pause_disabled:
		var img = get_viewport().get_texture().get_data()
		img.flip_y()
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		tex.set_size_override(Vector2(1024,768))
		$pause_menu/pause_blur_background.texture = tex
		$pause_menu/pause_blur_background.material.set_shader_param("effect_on", true)
		yield(get_tree(), "idle_frame")
		$pause_menu.visible = true
		get_tree().paused = true


func _physics_process(_delta):
	var rtt = get_node("game_viewport_container/3d_background_viewport").get_texture()
	$game_viewport_container/game_viewport/rendered_background.texture = rtt
	pass


func _on_game_viewport_end_stage_DEMO():
	var fade_res = load("res://ui/fade.tscn")
	var fade = fade_res.instance()
	add_child(fade)
	yield(get_tree().create_timer(5, false),"timeout")
	PlayerVars.reset_vars()
	Global.return_to_main_menu()
