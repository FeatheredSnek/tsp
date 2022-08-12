extends Node2D

var creep_meele_standard = preload("res://entities/creeps/creep_meele_standard.tscn")
var creep_ranged_standard = preload("res://entities/creeps/creep_ranged_standard.tscn")
var creep_ranged_super = preload("res://entities/creeps/creep_ranged_super.tscn")
var bullet_ball = preload("res://entities/bullets/bullet_ball_32/bullet_ball_32.tscn")
var bullet_arrow = preload("res://entities/bullets/bullet_arrow_16/bullet_arrow_16.tscn")
var bullet_rice = preload("res://entities/bullets/bullet_rice/bullet_rice.tscn")
var bullet_bordered = preload("res://entities/bullets/bullet_bordered_24/bullet_bordered_24.tscn")

signal pattern_over
signal drop_items(droptable, drop_position)


func _ready():
	creep_loop_1()


func creep_pattern_await(time:float):
	$pattern_timer.start(time)
	return $pattern_timer


### ATTACK ORDERS

func group_move_attack_wiggle_cycle(group: Array, midpoint_target: Vector2, final_target: Vector2, spawn_time: float, wiggle_time: float, runaway_time: float, wiggle_count: float):
	for creep in group:
		creep.move_to_point(creep.position + Vector2(0, midpoint_target.y), spawn_time+0.4*randf(), Tween.EASE_OUT)
	yield(get_tree().create_timer(spawn_time+0.4, false),"timeout")
	for _i in range(wiggle_count):
		for creep in group:
			if is_instance_valid(creep) and creep.alive:
				creep.meele_triplet(bullet_rice, Bullet.BLUE)
				creep.move_to_point(creep.position+(Vector2(20,0).rotated(TAU*randf())), wiggle_time, Tween.EASE_OUT)
		yield(get_tree().create_timer(wiggle_time, false),"timeout")
	for creep in group:
		if is_instance_valid(creep) and creep.alive:
			var target = Vector2(final_target.x, final_target.y * (0.9 + 0.2 * randf()))
			creep.move_to_point(target, runaway_time, Tween.EASE_IN)


func ranged_exploder_spawn_attack_wiggle(creep:Creep, midpoint_target: Vector2, _final_target: Vector2, spawn_time: float, wiggle_time: float, runaway_time: float, wiggle_count: float):
	creep.move_to_point(midpoint_target, spawn_time, Tween.EASE_OUT)
	yield(get_tree().create_timer(spawn_time+0.2, false),"timeout")
	if is_instance_valid(creep) and creep.alive:
		creep.ranged_explode(bullet_arrow, Bullet.GOLD, 18, 3)
	yield(get_tree().create_timer(0.4, false),"timeout")
	for _i in range(wiggle_count):
		if is_instance_valid(creep) and creep.alive:
			creep.move_to_point(creep.position + (Vector2(20,0).rotated(TAU*randf())), wiggle_time, Tween.EASE_OUT)
		yield(get_tree().create_timer(wiggle_time, false),"timeout")
		if is_instance_valid(creep) and creep.alive:
			creep.move_to_point(creep.position + Vector2(0, -300), runaway_time, Tween.EASE_OUT)


func spawn_and_march(how_many:int, spawn_position: Vector2, final_target: Vector2, move_time: float, gap_time: float):
	for i in range(how_many):
		var pos = spawn_position + Vector2(10*randf(), 150*randf())
		var drops = Creep.droptables.no_drop
		if i%3 == 0:
			drops = Creep.droptables.sitems_small
		var creep = creep_spawner(Creep.MEELE, pos, drops)
		var target = final_target + (spawn_position - creep.position)
		var time = 0.8 * move_time + 0.2 * move_time * randf()
		creep.move_to_point(target, time, -1)
		yield(get_tree().create_timer(gap_time, false),"timeout")


func meele_from_side_attack_run(creep:Creep, midpoint_target: Vector2, final_target: Vector2, spawn_time: float, runaway_time: float):
	creep.move_to_point(midpoint_target, spawn_time, Tween.EASE_OUT)
	yield(get_tree().create_timer(spawn_time, false),"timeout")
	if is_instance_valid(creep) and creep.alive:
		if creep.position.x < 300:
			creep.meele_arrow(bullet_ball, Bullet.LIME)
		else:
			creep.meele_arrow(bullet_ball, Bullet.CYAN)
		creep.move_to_point(final_target, runaway_time, Tween.EASE_IN)


func supercreep_cycle(supercreep, midpoint_target: Vector2, final_target: Vector2, spawn_time: float, runaway_time: float):
	supercreep.move_to_point(midpoint_target, spawn_time, Tween.EASE_OUT)
	yield(get_tree().create_timer(spawn_time+1, false), "timeout")
	supercreep.supercreep_attack_cycle_1(bullet_ball, bullet_bordered, 1, 4)
	yield(get_tree().create_timer(33, false), "timeout")
	if is_instance_valid(supercreep) and supercreep.alive:
		supercreep.move_to_point(final_target, runaway_time, Tween.EASE_IN_OUT)


func creep_spawner(type:int, spawnpoint:Vector2, droptable:Array):

	var creep_to_add
	match type:
		Creep.MEELE:
			creep_to_add = creep_meele_standard.instance()
		Creep.RANGED:
			creep_to_add = creep_ranged_standard.instance()
		Creep.SUPER:
			creep_to_add = creep_ranged_super.instance()

	creep_to_add.position = spawnpoint
	creep_to_add.bullet_packed = bullet_ball
	creep_to_add.creep_droptable = droptable
	creep_to_add.add_to_group("EnemyCreeps")
	add_child(creep_to_add)
	creep_to_add.connect("creep_signal_dead", self, "_on_creep_death")
	
	return creep_to_add


func remove_creeps():
	for creep in get_tree().get_nodes_in_group("EnemyCreeps"):
		creep.queue_free()


func _on_creep_death(creep_droptable, creep_position):
	emit_signal("drop_items", creep_droptable, creep_position)


func _on_game_over():
	$pattern_timer.stop()


##### MAIN CREEP LOOP

func creep_loop_1():
	
	# meele group 1
	var g1 = [null, null, null]
	for i in range(3):
		var pos = $spawnpoint_1_1.position + Vector2(-70 + (i * 70) + 20 * randf(), -20 * randf())
		g1[i] = creep_spawner(Creep.MEELE, pos, Creep.droptables.combined_small)
	group_move_attack_wiggle_cycle(g1, $midpoint_1_1.position, $target_1_1.position, 1.5, 1, 3, 4)

	yield(creep_pattern_await(6),"timeout")

	# meele group 2
	var g2 = [null, null, null]
	for i in range(3):
		var pos = $spawnpoint_1_2.position + Vector2(-70 + (i * 70) + 20 * randf(), -20 * randf())
		g2[i] = creep_spawner(Creep.MEELE, pos, Creep.droptables.combined_small)
	group_move_attack_wiggle_cycle(g2, $midpoint_1_2.position, $target_1_2.position, 1.5, 1, 3, 4)

	yield(creep_pattern_await(6),"timeout")

	# meele group 3
	var g3 = [null, null, null, null]
	for i in range(4):
		var pos = $spawnpoint_1_3.position + Vector2(-60 + (i * 60) + 20 * randf(), -20 * randf())
		g3[i] = creep_spawner(Creep.MEELE, pos, Creep.droptables.combined_small)
	group_move_attack_wiggle_cycle(g3, $midpoint_1_3.position, $target_1_3.position, 1.5, 1, 3, 4)

	yield(creep_pattern_await(6),"timeout")

	# meele group 4
	var g4 = [null, null, null, null]
	for i in range(4):
		var pos = $spawnpoint_1_4.position + Vector2(-60 + (i * 60) + 20 * randf(), -20 * randf())
		g4[i] = creep_spawner(Creep.MEELE, pos, Creep.droptables.combined_small)
	group_move_attack_wiggle_cycle(g4, $midpoint_1_4.position, $target_1_4.position, 1.5, 1, 3, 4)

	yield(creep_pattern_await(8),"timeout")

	# ranged pair 1
	var r11 = creep_spawner(Creep.RANGED, $spawnpoint_exploder_1.position, Creep.droptables.combined_big)
	var r12 = creep_spawner(Creep.RANGED, $spawnpoint_exploder_2.position, Creep.droptables.combined_big)
	ranged_exploder_spawn_attack_wiggle(r11, r11.position + Vector2(0,150), r11.position, 1.5, 1, 1.5, 3)
	ranged_exploder_spawn_attack_wiggle(r12, r12.position + Vector2(0,150), r12.position, 1.5, 1, 1.5, 3)

	yield(creep_pattern_await(3),"timeout")

	spawn_and_march(12, $spawnpoint_group_march_right.position, $target_group_march_right.position, 4, 0.2)

	yield(creep_pattern_await(3),"timeout")

	# ranged pair 2
	var r2 = [null, null]
	r2[0] = creep_spawner(Creep.RANGED, $spawnpoint_exploder_3.position, Creep.droptables.combined_big)
	r2[1] = creep_spawner(Creep.RANGED, $spawnpoint_exploder_4.position, Creep.droptables.combined_big)
	for r in r2.duplicate():
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)

	yield(creep_pattern_await(3),"timeout")

	spawn_and_march(12, $spawnpoint_group_march_left.position, $target_group_march_left.position, 4, 0.2)

	yield(creep_pattern_await(3),"timeout")

	# ranged pair 3
	var r3 = [null, null]
	r3[0] = creep_spawner(Creep.RANGED, $spawnpoint_exploder_5.position, Creep.droptables.combined_big)
	r3[1] = creep_spawner(Creep.RANGED, $spawnpoint_exploder_6.position, Creep.droptables.combined_big)
	for r in r3:
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)

	yield(creep_pattern_await(3),"timeout")

	spawn_and_march(12, $spawnpoint_group_march_right.position, $target_group_march_right.position, 4, 0.2)
	spawn_and_march(12, $spawnpoint_group_march_left.position, $target_group_march_left.position, 4, 0.2)

	yield(creep_pattern_await(3),"timeout")

	# ranged group
	var r4 = [null, null, null, null, null, null]
	for i in range(6):
		var pos = "spawnpoint_exploder_" + str(i+7)
		r4[i] = creep_spawner(Creep.RANGED, get_node(pos).position, Creep.droptables.combined_medium)
	for r in r4:
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)
		yield(creep_pattern_await(0.4),"timeout")

	yield(creep_pattern_await(6),"timeout")

	# side meele
	var sidespawn_positions = PoolVector2Array()
	sidespawn_positions.append($spawnpoint_side_left_1.position)
	sidespawn_positions.append($spawnpoint_side_right_1.position)
	sidespawn_positions.append($spawnpoint_side_left_2.position)
	sidespawn_positions.append($spawnpoint_side_right_3.position)
	sidespawn_positions.append($spawnpoint_side_left_3.position)
	sidespawn_positions.append($spawnpoint_side_right_2.position)
	for i in range(sidespawn_positions.size()):
		var midpoint = sidespawn_positions[i].move_toward(Vector2(300,250),100)
		var target = Vector2(600 - sidespawn_positions[i].x, 300)
		var cs = creep_spawner(Creep.MEELE, sidespawn_positions[i], Creep.droptables.combined_medium)
		meele_from_side_attack_run(cs, midpoint, target, 2, 3)
		yield(creep_pattern_await(2), "timeout")
	sidespawn_positions.invert()
	for i in range(sidespawn_positions.size()):
		var midpoint = sidespawn_positions[i].move_toward(Vector2(300,250),100)
		var target = Vector2(600 - sidespawn_positions[i].x, 300)
		var cs = creep_spawner(Creep.MEELE, sidespawn_positions[i], Creep.droptables.combined_big)
		meele_from_side_attack_run(cs, midpoint, target, 2, 3)
		yield(creep_pattern_await(1), "timeout")
	
	# ranged group inverted
	var r5 = []
	for i in range(6):
		var pos = "spawnpoint_exploder_" + str(7-i)
		r5.append(creep_spawner(Creep.RANGED, get_node(pos).position, Creep.droptables.combined_medium))
	for r in r5:
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)
		yield(get_tree().create_timer(0.4, false),"timeout")
	
	yield(creep_pattern_await(6),"timeout")
	
	# supercreep
	var sc = creep_spawner(Creep.SUPER, $spawnpoint_supercreep_1.position, Creep.droptables.boss_drop)
	supercreep_cycle(sc, $target_supercreep_1.position, sc.position, 1.5, 1.5)

	yield(creep_pattern_await(28), "timeout")
	
	# side meele fast
	for i in range(sidespawn_positions.size()):
		var midpoint = sidespawn_positions[i].move_toward(Vector2(300,250),100)
		var target = Vector2(600 - sidespawn_positions[i].x, 300)
		var cs = creep_spawner(Creep.MEELE, sidespawn_positions[i], Creep.droptables.combined_medium)
		meele_from_side_attack_run(cs, midpoint, target, 2, 3)
		yield(creep_pattern_await(1.2), "timeout")
	sidespawn_positions.invert()
	for i in range(sidespawn_positions.size()):
		var midpoint = sidespawn_positions[i].move_toward(Vector2(300,250),100)
		var target = Vector2(600 - sidespawn_positions[i].x, 300)
		var cs = creep_spawner(Creep.MEELE, sidespawn_positions[i], Creep.droptables.combined_big)
		meele_from_side_attack_run(cs, midpoint, target, 2, 3)
		yield(creep_pattern_await(0.6), "timeout")
	
	# ranged group ending
	var r6 = []
	for i in range(6):
		var pos = "spawnpoint_exploder_" + str(i+7)
		r6.append(creep_spawner(Creep.RANGED, get_node(pos).position, Creep.droptables.combined_medium))
	for r in r6:
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)
		yield(creep_pattern_await(0.4),"timeout")
	
	yield(creep_pattern_await(1),"timeout")
	
	# ranged group ending inverse
	var r7 = []
	for i in range(6):
		var pos = "spawnpoint_exploder_" + str(i+7)
		r7.append(creep_spawner(Creep.RANGED, get_node(pos).position, Creep.droptables.combined_medium))
	for r in r7:
		ranged_exploder_spawn_attack_wiggle(r, r.position + Vector2(0,150), r.position, 1.5, 1, 1.5, 3)
		yield(creep_pattern_await(0.4),"timeout")

	yield(creep_pattern_await(7),"timeout")
	
	remove_creeps()
	
	emit_signal("pattern_over")

