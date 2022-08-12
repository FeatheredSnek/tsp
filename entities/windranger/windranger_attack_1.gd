extends Attack

var animator


func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()
	animator = boss_unit.get_node("wr_sprite_animations")


# ---------- PATTERN ----------


func attack_cycle():

	for i in range (3):
		if i > 0 and PlayerVars.position.x < 300:
			if not boss_unit.position == $pos_left.position:
				boss_unit.move_to($pos_left.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			else:
				boss_unit.move_to($pos_middle.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		elif i > 0 and PlayerVars.position.x >= 300:
			if not boss_unit.position == $pos_left.position:
				boss_unit.move_to($pos_right.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			else:
				boss_unit.move_to($pos_middle.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		yield(cycle_await(1),"timeout")
		emit_signal("request_vfx", VfxServer.WR_GATHER, boss_unit.position)
		emit_signal("request_sfx", SfxServer.BOSS_ATTACK_GATHER)
		yield(cycle_await(1.8),"timeout")
		emit_signal("request_ripple_vfx", boss_unit.position, VfxServer.OUTWARD, 1)
		explode()	
		yield(cycle_await(6),"timeout")
		volley()
		yield(cycle_await(6),"timeout")
		boss_unit.animate_idle()
		yield(cycle_await(6),"timeout")


func explode():
	
	var count = 48 + 24*PlayerVars.difficulty
	var rot = 1.0 / count
	
	for k in range(3 - 1*PlayerVars.difficulty):    
		
		boss_unit.animate_attack(false)
		for j in range(3 + 2*PlayerVars.difficulty):
			
			for i in range(count):
				var bullet_to_add = bullet_rice.instance()
				bullet_to_add.position = boss_unit.position
				bullet_to_add.speed = 280
				bullet_to_add.bullet_color = Bullet.BLUE
				bullet_to_add.direction = Vector2.DOWN.rotated(rot * i * TAU + 0.1*j + 0.1*k) #DOWN.rotated(rot * i * TAU * randf())
				bullet_to_add.add_to_group("EnemyBullets")
				bullet_to_add.custom = true
				add_child(bullet_to_add)
			
			emit_signal("request_shot_vfx", boss_unit.position, Bullet.BLUE, 1.2)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
			
			$explode_timer_1.start(0.2)
			yield($explode_timer_1, "timeout")
		
		$explode_timer_2.start(2)
		yield($explode_timer_2, "timeout")


func volley():
	
	var colors = [Bullet.LIME, Bullet.CYAN]
	
	boss_unit.animate_attack(true)
	var count = 4
	var volleys_count = 12
	var volleys_factor = 2 * TAU / volleys_count + 0.6
	var factor1 = 0.05 * PI
	var factor2 = 0.12 * PI / count
	var direction_vector = (PlayerVars.position - boss_unit.position).normalized()
	for k in range(volleys_count):
		
		for j in range(count):
			
			for i in range(count+3):
				var bullet_to_add = bullet_ball.instance()
				bullet_to_add.position = boss_unit.position
				bullet_to_add.speed = 20 + j*23 + i*10
				bullet_to_add.direction = direction_vector.rotated((i-(count/3))*factor1 + j*factor2 + k*volleys_factor)
				bullet_to_add.add_to_group("EnemyBullets")
				bullet_to_add.custom = false
				bullet_to_add.bullet_color = colors[0]
				add_child(bullet_to_add)
				
			emit_signal("request_shot_vfx", boss_unit.position, colors[0], 1)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
			
			$volley_timer_1.start(0.08)
			yield($volley_timer_1, "timeout")
		
		colors.invert()
		$volley_timer_2.start(0.2)
		yield($volley_timer_2, "timeout")



