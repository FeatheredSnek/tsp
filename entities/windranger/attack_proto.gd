extends Node2D

class_name Attack

var bullet_rice = preload("res://entities/bullets/bullet_rice/bullet_rice.tscn")
var bullet_ball = preload("res://entities/bullets/bullet_ball_32/bullet_ball_32.tscn")

export (int) var attack_hp
export (int) var attack_total_time
export (bool) var is_spell
export (bool) var is_last_spell
export (String) var spell_name
export (int) var spell_max_bonus

var boss_unit
var attack_timer
var countdown_timer
var cycle_timer
var bonus_update_timer
var bonus
var invunerable_to_player_attacks = true

signal last_spell_ended(spell_name, time_bonus)
signal attack_ended(attack_node_name, is_spell, time_bonus)
signal update_hp(new_value)
signal update_time(new_time_value)
signal update_bonus(new_bonus_value)
signal attack_started(init_health, init_time)

signal request_vfx(type, pos)
signal request_shot_vfx(pos, col, scl)
signal request_ripple_vfx(pos, dir, time)
signal request_bloom_vfx(time)
signal request_sfx(type)
signal request_shot_sfx(shot_type)


func _ready():
	spell_max_bonus += spell_max_bonus * 0.5 * PlayerVars.difficulty


func connect_signals():
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	countdown_timer.connect("timeout", self, "_on_countdown_timer_timeout")
	if is_spell:
		bonus_update_timer.connect("timeout", self, "_on_bonus_update_timer_timeout")
	self.connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
	self.connect("request_shot_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "shot_vfx")
	self.connect("request_ripple_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "ripple_vfx")
	self.connect("request_bloom_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "bloom_vfx")
	self.connect("request_sfx", get_viewport(), "sfx_request")
	self.connect("request_shot_sfx", get_viewport(), "sfx_request_enemy_shot")


func cycle_await(time):
	cycle_timer.start(time)
	return cycle_timer


func attack_start():
	emit_signal("attack_started", attack_hp, attack_total_time)
	invunerable_to_player_attacks = false
	if attack_total_time < 1:
		attack_total_time = 10
	attack_timer.wait_time = attack_total_time
	attack_timer.start()
	countdown_timer.start()
	if is_spell:
		bonus = spell_max_bonus
		bonus_update_timer.start()
	attack_cycle()


func attack_cycle():
	printerr("method 'attack_cycle' no present within attack node")
	pass



func attack_stop():
	
	attack_interrupt()
	clear_bullets()
	emit_signal("request_vfx", VfxServer.WR_ATTACK_END_EXP, boss_unit.position)
	emit_signal("request_sfx", SfxServer.ENEMY_EXPLODE)
	
	if not is_last_spell:
#		yield(get_tree().create_timer(1, false), "timeout")
		emit_signal("attack_ended", spell_name, is_spell, bonus)
		yield(get_tree().create_timer(1, false), "timeout")
		queue_free()
	else:
		emit_signal("last_spell_ended", spell_name, bonus)
		yield(get_tree().create_timer(1, false), "timeout")
		queue_free()



func attack_interrupt():
	invunerable_to_player_attacks = true
	boss_unit.get_node("movement_tween").stop_all()
	boss_unit.animate_idle()
	for child in get_children():
		if child is Timer:
			child.stop()
		elif child is Tween:
			child.stop_all()


func clear_bullets():
	var res = 20
	var time = 1
	var fac = float(time) / res
	remove_offscreen_bullets()
	yield(get_tree(),"idle_frame")
	for i in range(10):
		for b in get_tree().get_nodes_in_group("EnemyBullets"):
			if b.position.x < i * 60:
				b.clear()
		yield(get_tree().create_timer(fac, false), "timeout")
	for b in get_tree().get_nodes_in_group("EnemyBullets"):
		b.clear()


func remove_offscreen_bullets():
	for b in get_tree().get_nodes_in_group("EnemyBullets"):
		if b.position.y < -50 or b.position.y > 770 or b.position.x < -50 or b.position.x > 650:
			b.queue_free()


func animation():
	pass


func _on_hp_damaged(damage_value):
	attack_hp -= damage_value
	emit_signal("update_hp", attack_hp)
	if attack_hp < 1:
		attack_stop()


func _on_attack_timer_timeout():
	attack_stop()


func _on_countdown_timer_timeout():
	emit_signal("update_time", int(attack_timer.time_left))
	if attack_timer.time_left < 5:
		emit_signal("request_sfx", SfxServer.BOSS_WARNING)


func _on_bonus_update_timer_timeout():
	bonus -= spell_max_bonus / attack_total_time * 0.1
	bonus = int(clamp(bonus, 0, spell_max_bonus))
	emit_signal("update_bonus", int(bonus))


