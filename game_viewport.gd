extends Viewport

var p_item = preload("res://entities/scoring/p_item.tscn")
var s_item = preload("res://entities/scoring/s_item.tscn")
var star_item = preload("res://entities/scoring/star_item.tscn")

var intro = preload("res://ui/ingame/stage_intro_1.tscn")
var pattern_1 = preload("res://entities/creeps/creep_pattern_1.tscn")
var pattern_2 = preload("res://entities/windranger/windranger.tscn")
var dialogue_system = preload("res://ui/dialogues/dialogue_system.tscn")
var intro_node

var vfx_bullet_explode = preload("res://vfx/bullet_explode.tscn")
var autocollect = false

signal boss_entered(boss_unit)
signal end_stage
signal game_over


func _ready():
	$rendered_background.z_index = Global.CustomLayers.RENDERED_BACKGROUND - 5
	$bgm_server.play_bgm(BGMServer.STAGE_1)


func _physics_process(delta):
	check_autocollect()


func check_autocollect():
	if PlayerVars.hp > 0 and (PlayerVars.position.y < 200 or PlayerVars.shadow_status == true):
		for item in get_tree().get_nodes_in_group("Items"):
			item.is_homing = true


func _on_intro_spawn_timer_timeout():
	intro_node = intro.instance()
	intro_node.position = Vector2(65, 200)
	add_child(intro_node, true)
	intro_node.get_node("intro_animation").connect("animation_finished", self, "_on_intro_finished")


func _on_intro_finished(_a):
	call_deferred("remove_child", intro_node)
	var autocollect_helper_res = load("res://ui/ingame/autocollect_helper.tscn")
	var autocollect_helper = autocollect_helper_res.instance()
	autocollect_helper.position = Vector2(300,200)
	add_child(autocollect_helper)
	$creep_pattern_1_spawn.start()


func _on_windranger_spawn_timer_timeout():
	# TODO zrób na starcie wr niewrażliwą na ataki
	var windranger_pattern = pattern_2.instance()
	add_child(windranger_pattern)
	$player_inst.connect("bomb_away", windranger_pattern, "_on_player_bomb")
	$player_inst.connect("player_graze", windranger_pattern, "_on_player_graze")
	$player_inst.connect("hit", windranger_pattern, "_on_player_hit")
	#$player_inst.connect("player_dead", windranger_pattern, "_on_player_dead")
	windranger_pattern.connect("boss_ended", self, "_on_boss_ended")
	windranger_pattern.connect("drop_items", self, "_on_drop_items")
	connect("game_over", windranger_pattern, "_on_game_over")
	# DIALOG
	$player_inst.player_disable_controls()
	yield(get_tree().create_timer(1, false),"timeout")
	var dialogue = dialogue_system.instance()
	add_child(dialogue)
	dialogue.connect("dialogue_finished", self, "_on_dialogue_finished")
	dialogue.connect("dialogue_finished", windranger_pattern, "_on_dialogue_finished")
	dialogue.connect("dialogue_finished", get_parent().get_child(0).get_child(0), "_on_dialogue_finished")
	var wr_dialog = load("res://ui/dialogues/schemas/stage_1/schema_1_1.tres")
	dialogue.init_dialogue(wr_dialog)
	emit_signal("boss_entered", windranger_pattern.get_node("windranger_unit"))


func _on_creep_pattern_1_spawn_timeout():
	var creep_pattern_1 = pattern_1.instance()
	add_child(creep_pattern_1)
	creep_pattern_1.connect("pattern_over", self, "_on_creep_pattern_1_over")
	creep_pattern_1.connect("drop_items", self, "_on_drop_items")
	connect("game_over", creep_pattern_1, "_on_game_over")


func _on_creep_pattern_1_over():
	$windranger_spawn_timer.start()


func _on_dialogue_finished():
	$player_inst.player_enable_controls()
	$bgm_server.change_bgm(BGMServer.BOSS_1)


func _on_drop_items(droptable, drop_position):
	for p in range(droptable[0]):
		var pitem_to_add = p_item.instance()
		pitem_to_add.position = drop_position + Vector2(randf()*50, randf()*50)
		pitem_to_add.add_to_group("Items")
		call_deferred("add_child", pitem_to_add)
	for s in range(droptable[1]):
		var sitem_to_add = s_item.instance()
		sitem_to_add.position = drop_position + Vector2(randf()*50, randf()*50)
		sitem_to_add.add_to_group("Items")
		call_deferred("add_child", sitem_to_add)
	pass


func _on_bullet_cleared(bullet_position):
	var star_item_to_add = star_item.instance()
	star_item_to_add.position = bullet_position
	star_item_to_add.add_to_group("Items")
	call_deferred("add_child", star_item_to_add)


func _on_autocollect_area_area_entered(area):
	autocollect = true


func _on_autocollect_area_area_exited(area):
	autocollect = false


func _on_player_inst_shadow_entered():
	$background_animations.play("shadow")
	$bgm_server.lowpass_on()


func _on_player_inst_shadow_exited():
	$background_animations.play_backwards("shadow")
	$bgm_server.lowpass_off()


func _on_boss_ended():
	var demo_outro_res = load("res://ui/ingame/demo_outro.tscn")
	var demo_outro = demo_outro_res.instance()
	demo_outro.position = Vector2(65, 260)
	add_child(demo_outro)
	yield(get_tree().create_timer(10, false),"timeout")
	PlayerVars.save_highscore(1)
	Global.pause_disabled = true
	$player_inst.player_disabled_controls = true
	$bgm_server.end_fadeout(4.5)
	emit_signal("end_stage")



func _on_player_inst_player_dead():
	
	PlayerVars.save_highscore(1)
	
	for item in get_tree().get_nodes_in_group("Items"):
		item.is_homing = false
		item.set_nonhoming()
	
	emit_signal("game_over")
	
	Global.pause_disabled = true
	
	propagate_call("set_paused", [true])

	yield(get_tree().create_timer(1, false),"timeout")
	
	var game_over_splash_res = load("res://ui/ingame/game_over_splash.tscn")
	var game_over_splash = game_over_splash_res.instance()
	game_over_splash.position = Vector2(65, 200)
	add_child(game_over_splash)



func sfx_request_enemy_shot(shot_type:int):
	match shot_type:

		SfxServer.ENEMY_SHOT_1:
			$sfx_server/enemy_shot_1.play()
		SfxServer.ENEMY_SHOT_2:
			$sfx_server/enemy_shot_2.play()
		SfxServer.ENEMY_SHOT_QUIET:
			$sfx_server/enemy_shot_quiet.play()
		_:
			return
	pass


func sfx_request(sfx_type:int):
	match sfx_type:

		SfxServer.PLAYER_SHOT:
			$sfx_server/player_shot_regular.play()
		SfxServer.PLAYER_SHOT_SHADOW:
			$sfx_server/player_shot_shadowrealm.play()
		SfxServer.PLAYER_BOMB:
			$sfx_server/player_bomb.play()
		SfxServer.PLAYER_JEX_SHOT:
			$sfx_server/player_jex_shot.play()
		SfxServer.PLAYER_ENTER_SHADOWREALM:
			$sfx_server/player_enter_shadowrealm.play()
		SfxServer.PLAYER_EXIT_SHADOWREALM:
			$sfx_server/player_exit_shadowrealm.play()
		SfxServer.PLAYER_BULLET_HIT:
			$sfx_server/player_bullet_hit.play()
		SfxServer.PLAYER_BULLET_HIT_SHADOWREALM:
			$sfx_server/player_bullet_hit_shadowrealm.play()
		SfxServer.PLAYER_GET_HIT:
			$sfx_server/player_get_hit.play()
		SfxServer.PLAYER_COLLECT:
			$sfx_server/player_collect.play()
		SfxServer.PLAYER_GRAZE:
			$sfx_server/player_graze.play()
		SfxServer.PLAYER_SHADOWGAUGE_MAX:
			$sfx_server/player_shadowgauge_max.play()

		SfxServer.ENEMY_EXPLODE:
			$sfx_server/enemy_explode.play()
		SfxServer.BOSS_ATTACK_GATHER:
			$sfx_server/boss_attack_gather.play()
		SfxServer.BOSS_SPELL_GATHER:
			$sfx_server/boss_spell_gather.play()
		SfxServer.BOSS_BLING:
			$sfx_server/boss_bling.play()
		SfxServer.BOSS_WARNING:
			$sfx_server/boss_warning.play()
		SfxServer.ENEMY_WIND:
			$sfx_server/enemy_wind.play()
		SfxServer.BOSS_END:
			for _i in range(30):
				$sfx_server/enemy_explode.play()
				yield(get_tree().create_timer(0.1 + 0.1 * randf(), false),"timeout")
		_:
			return
	pass
