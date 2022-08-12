extends Attack


func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()


# ----------------- PATTERN ----------------


func attack_cycle():
	
	for i in range(3):
		
		emit_signal("request_vfx", VfxServer.WR_GATHER, boss_unit.position)
		emit_signal("request_ripple_vfx", boss_unit.position, VfxServer.INWARD, 2)
		emit_signal("request_sfx", SfxServer.BOSS_ATTACK_GATHER)
		
		yield(cycle_await(1.5),"timeout")
		
		explode2()
		
		yield(cycle_await(17),"timeout")
		
		balls_explode()
		
		yield(cycle_await(13),"timeout")
		
		if i == 0 or i == 2:
			if PlayerVars.position.x < 300:
				boss_unit.move_to($pos_left.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			else:
				boss_unit.move_to($pos_right.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		else:
			boss_unit.move_to($pos_middle.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		
		yield(cycle_await(1),"timeout")



func explode2():

	var rice_colors = [Bullet.BLUE, Bullet.CYAN, Bullet.BLUE]
	var wr_pos = boss_unit.position
	var count = 48 + 12*PlayerVars.difficulty
	var rotation_sign = -1
	var rotation_factor = TAU / count
	
	for k in range(3):
		
		for j in range(6):
			
			for i in range(count):
				var bullet_to_add = bullet_rice.instance()
				bullet_to_add.position = wr_pos
				bullet_to_add.speed = 850
				bullet_to_add.acceleration = -22
				bullet_to_add.min_speed = 65
				bullet_to_add.max_speed = 850
				bullet_to_add.bullet_color = rice_colors[k]
				bullet_to_add.direction = Vector2.DOWN.rotated(rotation_factor * i * rotation_sign + 0.03 * j)
				bullet_to_add.t1 = rotation_sign
				bullet_to_add.add_to_group("EnemyBullets")
				bullet_to_add.custom = true
				bullet_to_add.custom_type = "wr_3_explode_2"
				add_child(bullet_to_add)
			
			emit_signal("request_shot_vfx", boss_unit.position, rice_colors[k], 1.5)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
			
			boss_unit.animate_attack(false)
			$explode_timer_1.start(0.8)
			yield($explode_timer_1,"timeout")
			rotation_sign *= -1
		
		$explode_timer_2.start(1)
		yield($explode_timer_2,"timeout")
		rotation_sign *= -1
		rotation_factor += 0.353 * PI #0.4



func balls_explode():

	var balls = []
	var spacing = 12
	var count
	var rotation_factor
	var balls_colors = [Bullet.GREEN, Bullet.LIME, Bullet.YELLOW]	
	
	for j in range(3):
		var balls_single_volley = []
		count = int( (2 * PI * (80 + 40 * j))/spacing )
		var time = 0.02 #1.0 / count
		rotation_factor = TAU / count
		var isign = 1
		var ifactor = 0
		for i in range(count):
			var rot = Vector2.UP.rotated(rotation_factor * i + 0.225 * j)
			var jfactor = (80 + 40 * j)
			
			if (i%3) == 0:
				isign *= -1
			
			ifactor += 8 * isign
			
			var pos = boss_unit.position + ( rot * ( jfactor + ifactor ) )
			
			var bullet_to_add = bullet_ball.instance()
			bullet_to_add.position = pos
			bullet_to_add.speed = 0
			bullet_to_add.acceleration = 0
			bullet_to_add.min_speed = 0
			bullet_to_add.max_speed = 20
			bullet_to_add.direction = rot
			bullet_to_add.bullet_color = balls_colors[j]
			bullet_to_add.add_to_group("EnemyBullets")
			bullet_to_add.add_to_group("ExplodingBalls")
			bullet_to_add.custom = true
			bullet_to_add.custom_type = "wr_3_bigball_explode"
			add_child(bullet_to_add)
			balls_single_volley.append(bullet_to_add)
			
			emit_signal("request_shot_vfx", bullet_to_add.position, balls_colors[j], 1.0)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_QUIET)
			
			$balls_timer_1.start(time)
			yield($balls_timer_1,"timeout")
		
		balls.append(balls_single_volley)
	
#	Vfx.ripple_background_outward(boss_unit.position, false, 1)
	emit_signal("request_ripple_vfx", boss_unit.position, VfxServer.OUTWARD, 1)
	boss_unit.animate_attack(false)
	
	$balls_timer_2.start(0.2)
	yield($balls_timer_2,"timeout")
	
	emit_signal("request_sfx", SfxServer.ENEMY_WIND)
	for volley in balls:
		for bullet in volley:
			if is_instance_valid(bullet) and bullet.is_in_group("ExplodingBalls"):
				bullet.acceleration = 6
		$balls_timer_3.start(0.3)
		yield($balls_timer_3,"timeout")

