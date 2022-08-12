extends Node2D

var attack_counter = 0
var attack_count = 6


signal attack_stop_signal(bonus_gained)
signal attack_start_signal(attack_name, attack_type, attack_health, attack_time, attack_bonus)
signal attack_cycle_start()
signal attack_cycle_stop()
signal dialogue_end()

signal boss_ended()
signal drop_items(spell_droptable, windranger_position)
signal request_ending_vfx(pos)
signal request_sfx(type)


func _ready():
	self.connect("request_ending_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "boss_end_vfx")
	self.connect("request_sfx", get_viewport(), "sfx_request")
	$windranger_unit.position = $starting_position.position
	$windranger_ui.z_index = Global.CustomLayers.UI_INGAME
	$spellcard_background.z_index = Global.CustomLayers.BOSS_BACKGROUND - 5
	yield(boss_cycle_await(0.2), "timeout")
	enter_scene()


func get_phases_left():
	var phase_list = []
	for child in get_children():
		if child is Attack:
			if child.is_spell:
				phase_list.append("spell")
			else:
				phase_list.append("attack")
	return phase_list


func get_first_attack_data():
	for child in get_children():
		if child is Attack:
			return [child.attack_hp, child.attack_total_time]


func boss_cycle_await(time:float):
	$cycle_timer.start(time)
	return $cycle_timer


func _physics_process(delta):
	pass


func end_current_attack():
	get_child(0).attack_stop()


func enter_scene():
	$windranger_unit.move_to($default_position.position, 1, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$windranger_ui.construct_ui(get_phases_left(), get_first_attack_data())


func start_attack_cycle():
	emit_signal("attack_cycle_start")
	start_next_queued_attack()


func start_next_queued_attack():
	
	var queued_attack = get_child(0)

	emit_signal("attack_start_signal", queued_attack.spell_name, queued_attack.is_spell, queued_attack.attack_hp, queued_attack.attack_total_time, queued_attack.spell_max_bonus)

	if queued_attack.is_spell:
		yield(boss_cycle_await(2), "timeout")
		$spell_background_animations.play("spell_background_enable")
		yield(boss_cycle_await(1), "timeout")
		$windranger_unit/wr_seal_animations.play("inner_seal_appear")
		$windranger_unit/wr_seal_rotate.play("wr_seals_rotate")
		yield(boss_cycle_await(1), "timeout")
	
	queued_attack.attack_start()
	attack_counter += 1



func _on_windranger_area_area_entered(area):
	if not get_child(0).invunerable_to_player_attacks:
		get_child(0)._on_hp_damaged(area.player_bullet_damage)



func _on_attack_ended(attack_name, is_spell, attack_bonus):
	
	emit_signal("attack_stop_signal", attack_bonus)
	$windranger_unit.animate_idle()
	if is_spell:
		emit_signal("drop_items", Creep.droptables.boss_spell_drop, $windranger_unit.position)
	else:
		emit_signal("drop_items", Creep.droptables.boss_drop, $windranger_unit.position)

	if is_spell:
		PlayerVars.score += attack_bonus
		$spell_background_animations.play_backwards("spell_background_enable")
		yield(boss_cycle_await(1), "timeout")
		$windranger_unit/wr_seal_animations.play("inner_seal_disappear")

	yield(boss_cycle_await(3), "timeout")
	$windranger_unit.move_to($default_position.position, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	yield(boss_cycle_await(2), "timeout")
	start_next_queued_attack()



func _on_last_spell_ended(spell_name, spell_bonus):
	
	$windranger_unit/windranger_area.call_deferred("set_monitoring", false)
	
	$windranger_unit/wr_sprite.visible = false
	emit_signal("request_ending_vfx", $windranger_unit.position)
	emit_signal("request_sfx", SfxServer.BOSS_END)
	$windranger_unit/wr_seal_animations.play("inner_seal_disappear_ending")
	yield(boss_cycle_await(2.5),"timeout")
	remove_child($windranger_unit)
	$spell_background_animations.play_backwards("spell_background_enable")
	yield(boss_cycle_await(2),"timeout")
	emit_signal("attack_cycle_stop")
	emit_signal("attack_stop_signal", spell_bonus)
	yield(boss_cycle_await(10),"timeout")
	emit_signal("boss_ended")


func spell_background_enable():
	$spellcard_background.visible = true

func spell_background_disable():
	$spellcard_background.visible = false

func spell_seal_enable():
	$windranger_unit/wr_seal_animations.play("inner_seal_appear")
	$windranger_unit/wr_seal_rotate.play("wr_seals_rotate")

func spell_seal_disable():
	$windranger_unit/wr_seal_animations.play("inner_seal_disappear")
	yield($windranger_unit/wr_seal_animations,"animation_finished")
	$windranger_unit/wr_seal_rotate.stop()


func _on_dialogue_finished():
	emit_signal("dialogue_end")
	yield(boss_cycle_await(1),"timeout")
	start_attack_cycle()
	pass


func _on_player_bomb():
	if get_child(0).is_spell and get_child(0).bonus is int:
		get_child(0).bonus -= get_child(0).bonus / 5


func _on_player_graze():
	if get_child(0).is_spell and get_child(0).bonus is int:
		PlayerVars.score += PlayerVars.graze_during_spell_bonus


func _on_player_hit():
	if get_child(0).is_spell and get_child(0).bonus is int:
		get_child(0).bonus -= get_child(0).bonus / 2


func _on_player_dead():
	get_child(0).attack_interrupt()
	get_child(0).attack_timer.stop()
	get_child(0).countdown_timer.stop()
	pass


func _on_game_over():
	get_child(0).attack_interrupt()
