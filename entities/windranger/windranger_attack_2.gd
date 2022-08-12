extends Attack

var stream_rotation_mod = PI
var increase_counter = 0

var composite_arrow_colors = [Bullet.CYAN, Bullet.LIME, Bullet.YELLOW]

func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()


#------------ PATTERN -------------


func attack_cycle():
	for i in range(2):
		
		$cycle_timer.start(1.5)
		yield($cycle_timer,"timeout")
		
		emit_signal("request_vfx", VfxServer.WR_GATHER, boss_unit.position)
		emit_signal("request_ripple_vfx", boss_unit.position, VfxServer.INWARD, 1.8)
		emit_signal("request_sfx", SfxServer.BOSS_ATTACK_GATHER)
		
		$cycle_timer.start(1.0)
		yield($cycle_timer,"timeout")
		
		boss_unit.animate_attack(true)
		$cycle_timer.start(0.5)
		yield($cycle_timer, "timeout")
		
		streams()
		$cycle_timer.start(10)
		yield($cycle_timer,"timeout")
		boss_unit.animate_idle()
		arrows_cycle()
		$cycle_timer.start(22)
		yield($cycle_timer,"timeout")
		reset_vars()


func reset_vars():
	stream_rotation_mod = PI
	increase_counter = 0


func _on_t_increase_rotation_timeout():
	increase_stream_rotation()


func increase_stream_rotation():
	var factor = 0.03
	var acceleration = 0.005
	while increase_counter < 200:
		stream_rotation_mod -= factor + clamp(increase_counter, 0, 120) * acceleration
		increase_counter += 1
		$stream_rotation_timer.start(0.06)
		yield($stream_rotation_timer,"timeout")


func single_stream(stream_rotation):
	
	var bulletcount = 120
	
	for i in range(bulletcount):
		var bullet_to_add = bullet_rice.instance()
		bullet_to_add.position = boss_unit.position
		bullet_to_add.bullet_color = Bullet.BLUE
		bullet_to_add.speed = 220
		bullet_to_add.direction = Vector2.DOWN.rotated(stream_rotation + stream_rotation_mod)
		bullet_to_add.add_to_group("EnemyBullets")
		bullet_to_add.custom = true
		bullet_to_add.custom_type = "wr_2_stream"
		add_child(bullet_to_add)
		
		if i%2 == 0:
			emit_signal("request_shot_vfx", boss_unit.position, Bullet.BLUE, 1)
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
		
		$stream_spawn_timer.start(0.06)
		yield($stream_spawn_timer,"timeout")


func streams():
	$t_increase_rotation.start()
	var streamcount = 6 + 1*PlayerVars.difficulty
	for j in range(streamcount):
		single_stream(TAU / streamcount * j)


func arrows_cycle():
	var direction_vector
	var mirror = 1
	var volleys_count = 3 # tyle volleyów
	var directons_count = 5 # tyle kierunków
	var rotation_factor = TAU / directons_count
	var pause_time = 1.9
	var move_time = 1
	
	if PlayerVars.position.x < 300:
		get_parent().get_node("windranger_unit").move_to($pos_left.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		get_parent().get_node("windranger_unit").move_to($pos_right.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	$arrows_cycle_timer.start(move_time+0.2)
	yield($arrows_cycle_timer,"timeout")

	direction_vector = (PlayerVars.position - boss_unit.position).normalized()
	for i in range(volleys_count):
		boss_unit.animate_attack(true)
		mirror *= -1
		for j in range(directons_count):
			composite_arrow(direction_vector.rotated(j * rotation_factor), mirror, composite_arrow_colors[i])
		$arrows_cycle_timer.start(pause_time)
		yield($arrows_cycle_timer,"timeout")
	boss_unit.animate_idle()
	
	get_parent().get_node("windranger_unit").move_to($pos_middle.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	$arrows_cycle_timer.start(move_time+0.2)
	yield($arrows_cycle_timer,"timeout")
	boss_unit.animate_attack(true)
	direction_vector = (PlayerVars.position - boss_unit.position).normalized()
	for i in range(volleys_count):
		mirror *= -1
		for j in range(directons_count):
			composite_arrow(direction_vector.rotated(j * rotation_factor), mirror, composite_arrow_colors[i])
		$arrows_cycle_timer.start(pause_time)
		yield($arrows_cycle_timer,"timeout")
	boss_unit.animate_idle()
	
	if PlayerVars.position.x < 300:
		get_parent().get_node("windranger_unit").move_to($pos_left.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		get_parent().get_node("windranger_unit").move_to($pos_right.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	$arrows_cycle_timer.start(move_time+0.2)
	yield($arrows_cycle_timer,"timeout")
	boss_unit.animate_attack(true)
	direction_vector = (PlayerVars.position - boss_unit.position).normalized()
	for i in range(volleys_count):
		mirror *= -1
		for j in range(directons_count):
			composite_arrow(direction_vector.rotated(j * rotation_factor), mirror, composite_arrow_colors[i])
		$arrows_cycle_timer.start(pause_time)
		yield($arrows_cycle_timer,"timeout")
	boss_unit.animate_idle()
	
	boss_unit.move_to($pos_middle.position, move_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	$arrows_cycle_timer.start(move_time+0.2)
	yield($arrows_cycle_timer,"timeout")


func arrows():
	var direction_vector
	var mirror = 1
	var count1 = 3
	var count2 = 5
	var rotation_factor = TAU / count2
	var pause_time = 1.9
	for i in range(3):
		direction_vector = (PlayerVars.position - boss_unit.position).normalized()
		mirror *= -1
		for j in range(5):
			composite_arrow(direction_vector.rotated(j * rotation_factor), mirror, composite_arrow_colors[i])
		$arrows_pause_timer.start(pause_time)
		yield($arrows_pause_timer,"timeout")



func composite_arrow(direction_to_player, mirror, color):
	
	var fac = 0.20
	
	for i in range(7):
		
		for j in range (i+1):
			var bullet_to_add = bullet_ball.instance()
			bullet_to_add.position = boss_unit.position
			bullet_to_add.speed = 1000
			bullet_to_add.min_speed = 120 + 220*PlayerVars.difficulty
			bullet_to_add.max_speed = 1000
			bullet_to_add.acceleration = -40
			bullet_to_add.bullet_color = color
			bullet_to_add.direction = direction_to_player.rotated((fac*j-0.333*fac*i)*mirror)
			bullet_to_add.add_to_group("EnemyBullets")
			bullet_to_add.custom = false
			add_child(bullet_to_add)
		
		emit_signal("request_shot_vfx", boss_unit.position, color, 1.4)
		emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
		
		$arrows_spawn_timer.start(0.2)
		yield($arrows_spawn_timer,"timeout")

