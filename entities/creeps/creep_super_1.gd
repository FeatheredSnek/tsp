extends Creep


func supercreep_cycle_await(time:float):
	$supercreep_cycle_timer.start(time)
	return $supercreep_cycle_timer



func supercreep_attack_cycle_1(bullet1, bullet2, difficulty_multiplier, cycles):
	
	for j in range(cycles):
		
		var direction_vector = (PlayerVars.position - position).normalized()
		super_volley(bullet1, Bullet.BLUE, 6 + 4*PlayerVars.difficulty, direction_vector, 0)
		for i in range(5):
			super_volley(bullet1, Bullet.BLUE, 6 + 4*PlayerVars.difficulty, direction_vector, 0.18 * i)
			super_volley(bullet1, Bullet.BLUE, 6 + 4*PlayerVars.difficulty, direction_vector, -0.18 * i)
			emit_signal("request_shot_vfx", position, Bullet.BLUE, 1.6)
			yield(supercreep_cycle_await(0.06 + 0.02*PlayerVars.difficulty),"timeout")
		
		yield(supercreep_cycle_await(0.2),"timeout")
		emit_signal("request_sfx", SfxServer.BOSS_ATTACK_GATHER)
		emit_signal("request_vfx", VfxServer.SC_GATHER, position)
		
		yield(supercreep_cycle_await(1.8),"timeout")

		super_random_spread(bullet2, 1, 200 + 100*PlayerVars.difficulty)
		
		yield(supercreep_cycle_await(4.5),"timeout")
		
		if j == 2:
			self.invunerable = false
		else:
			pass



func super_random_spread(bullet, duration, bullets_per_second):
	
	var inbetween_bullet_delay = 1.0 / bullets_per_second
	var vfx_spacing = int(0.03 * bullets_per_second)
	var acc_factor = 0.2*PlayerVars.difficulty
	
	for i in range(bullets_per_second * duration):
		var bullet_to_add = bullet.instance()
		bullet_to_add.bullet_color = round(randf())
		bullet_to_add.position = position
		bullet_to_add.direction = Vector2.ONE.rotated(TAU * randf())
		bullet_to_add.speed = 50 + (10 * randf())
		bullet_to_add.acceleration = acc_factor
		bullet_to_add.add_to_group("EnemyBullets")
		get_parent().add_child(bullet_to_add)
		
		if i % vfx_spacing == 0:
			emit_signal("request_shot_vfx", position, bullet_to_add.bullet_color, 1)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_QUIET)
		
		$creep_attack_timer.start(inbetween_bullet_delay)
		yield($creep_attack_timer,"timeout")



func super_volley(bullet, bullet_color, bullets_in_volley, direction_vector: Vector2, rotation_offset: float):
	
	var separation = 0.033
	var spd_factor = 150 * PlayerVars.difficulty
	
	for i in range(bullets_in_volley):
		
		emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_2)
		
		var bullet_to_add1 = bullet.instance()
		bullet_to_add1.bullet_color = bullet_color
		bullet_to_add1.position = position
		bullet_to_add1.direction = direction_vector.rotated(separation + rotation_offset)
		bullet_to_add1.speed = 400 + spd_factor
		bullet_to_add1.add_to_group("EnemyBullets")
		get_parent().add_child(bullet_to_add1)
		
		var bullet_to_add2 = bullet.instance()
		bullet_to_add2.bullet_color = bullet_color
		bullet_to_add2.position = position
		bullet_to_add2.direction = direction_vector.rotated(-1*separation + rotation_offset)
		bullet_to_add2.speed = 400 + spd_factor
		bullet_to_add2.add_to_group("EnemyBullets")
		get_parent().add_child(bullet_to_add2)
		
		$creep_attack_timer.start(0.06)
		yield($creep_attack_timer,"timeout")
