extends Area2D

class_name Creep

enum {MEELE, RANGED, SUPER}
enum CreepVfxType {MEELE_TYPE, RANGED_TYPE}

const droptables = {
	"no_drop"			: [0,0],
	"combined_small"	: [2,3],
	"combined_medium"	: [3,4],
	"combined_big"		: [5,6],
	"pitems_small"		: [2,0],
	"pitems_big"		: [4,0],
	"sitems_small"		: [0,2],
	"sitems_big"		: [0,5],
	"boss_drop"			: [10,12],
	"boss_spell_drop"	: [12,24]
	}

export (int) var hp = 4
export (bool) var invunerable = false
export (CreepVfxType) var creep_vfx_type = 0
export (int) var creep_score = 1000

var alive = true
var bullet_packed
var creep_droptable = [0, 0]

signal creep_signal_dead(drops_table, drop_position)
signal request_shot_vfx(pos, col, scl)
signal request_vfx(type, pos)
signal request_sfx(type)
signal request_shot_sfx(shot_type)



func _ready():
	
	var _errvfx1 = connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
	var _errvfx2 = connect("request_shot_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "shot_vfx")
	
	var _errsfx1 = connect("request_sfx", get_viewport(), "sfx_request")
	var _errsfx2 = connect("request_shot_sfx", get_viewport(), "sfx_request_enemy_shot")
	
	self.z_index = Global.CustomLayers.ENEMY_SPRITE


### MOVEMENT


func move_to_point(target, travel_time, easing):
	if easing < 0:
		$creep_movement_tween.interpolate_property(self, "position", null, target, travel_time)
	else:
		$creep_movement_tween.interpolate_property(self, "position", null, target, travel_time, Tween.TRANS_SINE, easing)
	if alive:
		$creep_movement_tween.start()
	
	var position_difference = abs(target.x - position.x)
	if travel_time > 0.5 and position_difference > 50:
		if target.x < position.x:
			$creep_sprite.flip_h = true
			movement_animation()
		else:
			$creep_sprite.flip_h = false
			movement_animation()


func _on_creep_movement_tween_tween_all_completed():
	if $creep_sprite.animation != "idle":
		stopping_animation()


func movement_animation():
	if $creep_sprite.animation != "turn_into_idle":
		$creep_sprite.play("turn_into_move")
		yield($creep_sprite,"animation_finished")
		$creep_sprite.play("move")


func stopping_animation():
	$creep_sprite.play("turn_into_idle")
	yield($creep_sprite,"animation_finished")
	$creep_sprite.play("idle")



### ATTACKS


func ranged_explode(bullet:PackedScene, bullet_color:int, volley_count:int, bullets_in_volley:int):
	
	emit_signal("request_shot_vfx", position, bullet_color, 1)
	emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
	
	var direction_to_player = (PlayerVars.position - position).normalized()
	
	for _j in range(bullets_in_volley + 2*PlayerVars.difficulty):
		for i in range(volley_count + 6*PlayerVars.difficulty):
			var bullet_to_add = bullet.instance()
			bullet_to_add.bullet_color = bullet_color
			bullet_to_add.position = position
			if PlayerVars.difficulty == 0:
				bullet_to_add.direction = direction_to_player.rotated(TAU / volley_count * i)
			else:
				bullet_to_add.direction = (PlayerVars.position - position).normalized().rotated(TAU / volley_count * i)
			bullet_to_add.speed = 300 + 100*PlayerVars.difficulty
			bullet_to_add.add_to_group("EnemyBullets")
			get_parent().add_child(bullet_to_add)
		$creep_attack_timer.start(0.08)
		yield($creep_attack_timer,"timeout")



func meele_triplet(bullet:PackedScene, bullet_color:int):
	
	emit_signal("request_shot_vfx", position, bullet_color, 1)
	emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
	
	var direction_vector = (PlayerVars.position - position).normalized()
	
	for j in range(1 + 3*PlayerVars.difficulty):
		for i in range(3):
			var bullet_to_add = bullet.instance()
			bullet_to_add.bullet_color = bullet_color
			bullet_to_add.position = position
			bullet_to_add.direction = direction_vector.rotated((i-1)*0.1*PI)
			bullet_to_add.speed = 150 + (50*j)
			bullet_to_add.add_to_group("EnemyBullets")
			get_parent().add_child(bullet_to_add)



func meele_arrow(bullet:PackedScene, bullet_color:int):
	
	emit_signal("request_shot_vfx", position, bullet_color, 2)
	emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
	
	var direction_vector = (PlayerVars.position - position).normalized().rotated(0.1*randf())
	
	var bullet_count = 7 + 6 * PlayerVars.difficulty
#	var bullet_factor = 3 + 3 * PlayerVars.difficulty
	
	for i in range(bullet_count):
		var bullet_to_add = bullet.instance()
		bullet_to_add.bullet_color = bullet_color
		bullet_to_add.position = position
		bullet_to_add.direction = direction_vector.rotated((i-int(bullet_count/2.0))*(0.04-0.015*PlayerVars.difficulty)*PI)
		bullet_to_add.speed = 250 - 20 * abs(i-int(bullet_count/2.0)) + 50*PlayerVars.difficulty
		bullet_to_add.acceleration = 0.4 * abs(i-int(bullet_count/2.0)) + 0.2* PlayerVars.difficulty
		bullet_to_add.min_speed = 0
		bullet_to_add.max_speed = 300
		bullet_to_add.add_to_group("EnemyBullets")
		get_parent().add_child(bullet_to_add)


### SIGNALS


func _on_creep_visibility_notifier_viewport_exited(_viewport):
	alive = false


func _on_creep_area_entered(area):
	if not invunerable:
		
		emit_signal("request_sfx", SfxServer.PLAYER_BULLET_HIT)
		
		PlayerVars.score += int(area.player_bullet_damage * 100)
		hp -= area.player_bullet_damage
		if hp < 1:
			die()


func die():
	if creep_vfx_type == 0:
		emit_signal("request_vfx", VfxServer.CREEP_MEELE_EXPLODE, position)
	else:
		emit_signal("request_vfx", VfxServer.CREEP_RANGED_EXPLODE, position)
	emit_signal("creep_signal_dead", creep_droptable, position)
	emit_signal("request_sfx", SfxServer.ENEMY_EXPLODE)
	PlayerVars.score += creep_score
	alive = false
	for c in get_children():
		if c is Timer:
			c.stop()
		elif c is Tween:
			c.stop_all()
	yield(get_tree(),"idle_frame")
	set_process(false)
	set_physics_process(false)
	if is_instance_valid(get_parent()):
		get_parent().remove_child(self)

