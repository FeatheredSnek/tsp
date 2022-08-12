extends Attack

var bullet_arrow = preload("res://entities/bullets/bullet_arrow_16/bullet_arrow_16.tscn")
var bullet_shackler = preload("res://entities/bullets/bullet_arrow_24/bullet_arrow_24.tscn")
var bullet_ball_shackle_res = preload("res://entities/bullets/bullet_ball_32/bullet_ball_32_shackleshot.tscn")
var shackle_pair_res = preload("res://entities/bullets/bullet_special_shackleshot/bullet_special_shackleshot.tscn")

var speeds = [100, 120, 200, 211, 300, 320, 330, 333, 355, 366, 300, 200, 250, 100, 120, 200, 211, 300, 320, 330, 333, 355, 366, 300, 200, 250, 100, 120, 200, 211, 300, 320, 330, 333, 355, 366, 300, 200, 250, 100, 120, 200, 211, 300, 320, 330, 333, 355, 366, 300, 200, 250]

var angles_set = [
	[0.444819, 0.228503, 0.872147, 0.902846, -0.459909, 0.442168, -0.275496, -0.348295, 0.795771, -0.153035, -0.702796, 0.217083, -0.715296, 0.139446, -0.455465, -0.460837, 0.106658, 0.751885, 0.924196, -0.465522, 0.067906, 0.201745, 0.464657, -0.868027, 0.883686, -0.472984, -0.375802, -0.42722, 0.446415, 0.567234],
	[-0.66485, 0.030281, -0.458796, -0.22339, 0.436161, -0.827258, -0.891832, -0.213455, -0.652408, 0.096789, 0.675863, 0.713565, -0.198983, -0.573797, -0.634966, -0.200021, 0.803748, 0.715317, -0.20601, -0.724678, 0.563123, 0.001381, -0.240035, -0.075736, -0.550874, -0.263613, -0.190061, -0.672505, -0.299382, 0.787262],
	[0.700373, -0.579954, -0.020534, 0.000734, -0.15211, 0.532466, -0.269615, 0.76304, -0.75898, 0.932516, 0.275657, -0.175767, -0.090206, -0.1928, -0.841037, -0.72734, 0.923476, 0.925339, -0.346859, 0.120158, 0.069413, -0.531145, -0.308523, -0.81812, -0.634685, -0.489727, -0.238523, -0.319197, -0.246447, 0.893073],
	[0.444819, 0.228503, 0.872147, 0.902846, -0.459909, 0.442168, -0.275496, -0.348295, 0.795771, -0.153035, -0.702796, 0.217083, -0.715296, 0.139446, -0.455465, -0.460837, 0.106658, 0.751885, 0.924196, -0.465522, 0.067906, 0.201745, 0.464657, -0.868027, 0.883686, -0.472984, -0.375802, -0.42722, 0.446415, 0.567234]
	]

var angles
var colors = [Bullet.GOLD, Bullet.RED, Bullet.GREEN, Bullet.CYAN]

func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.bonus_update_timer = $bonus_update_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()



func attack_cycle():
	
	yield(cycle_await(1),"timeout")
	var next_target = boss_unit.position
	
	for i in range(4):
		angles = angles_set[i]
		yield(cycle_await(0.5),"timeout")
		
		emit_signal("request_vfx", VfxServer.WR_LEAVES, next_target)
		emit_signal("request_sfx", SfxServer.BOSS_SPELL_GATHER)
		
		yield(cycle_await(1.3),"timeout")
		
		emit_signal("request_bloom_vfx", 0.2)
#		emit_signal("request_sfx", SfxServer.BOSS_BLING)
		
		yield(cycle_await(0.2),"timeout")
		
		shackleshot_series(25, 0.5)
		
		yield(cycle_await(11),"timeout")
		
		if PlayerVars.position.x < 300:
			next_target = boss_unit.move_to($pos_left.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		else:
			next_target = boss_unit.move_to($pos_right.position, 1, Tween.TRANS_SINE, Tween.EASE_OUT)	



func shackleshot_series(count:int, time_spacing:float):
	
	boss_unit.animate_attack(true)
	
	for i in range (count):
		
		$shackle_series_timer.start(time_spacing)
		yield($shackle_series_timer, "timeout")
		
		var color_mod = colors[int(angles[i]*3.99)]
		var bullet_to_add = shackle_pair_res.instance()
		bullet_to_add.position = boss_unit.position
		var rotation_offset = angles[i]
		bullet_to_add.direction = boss_unit.position.direction_to(PlayerVars.position).rotated(rotation_offset)
		bullet_to_add.starting_speed = speeds[i]
		bullet_to_add.rotation = TAU * angles[i] 
		bullet_to_add.pair_color = color_mod
		bullet_to_add.connect("connect_shackles", self, "_on_connect_shackle")
		add_child(bullet_to_add)
		
		emit_signal("request_shot_vfx", boss_unit.position, color_mod, 1.5)
		emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_2)
		
	boss_unit.animate_idle()



func _on_connect_shackle(pos_a:Vector2, pos_b:Vector2, col:int):
	
	var bullet_count = 10
	var a_b_direction = pos_a.direction_to(pos_b)
	var b_a_direction = a_b_direction.rotated(PI)
	var bullets_direction = a_b_direction.tangent()
	var bullets_direction_rev = bullets_direction.rotated(PI)
	var a_b_distance = pos_a.distance_to(pos_b)
	var bullet_spacing = a_b_distance / bullet_count
	
	for i in range(bullet_count):
		
		var bullet_to_add = bullet_arrow.instance()
		bullet_to_add.position = pos_a + a_b_direction * bullet_spacing * i
		bullet_to_add.direction = bullets_direction
		bullet_to_add.speed = 0
		bullet_to_add.max_speed = 200
		bullet_to_add.min_speed = 0
		bullet_to_add.custom = true
		bullet_to_add.custom_type = "wr_shackle_arrow"
		bullet_to_add.bullet_color = col
		bullet_to_add.add_to_group("EnemyBullets")
		add_child(bullet_to_add)
		
		var bullet_to_add_rev = bullet_arrow.instance()
		bullet_to_add_rev.position = pos_b + b_a_direction * bullet_spacing * i
		bullet_to_add_rev.direction = bullets_direction_rev
		bullet_to_add_rev.speed = 0
		bullet_to_add_rev.max_speed = 200
		bullet_to_add_rev.min_speed = 0
		bullet_to_add_rev.custom = true
		bullet_to_add_rev.custom_type = "wr_shackle_arrow"
		bullet_to_add_rev.bullet_color = col
		bullet_to_add_rev.add_to_group("EnemyBullets")
		add_child(bullet_to_add_rev)
		
		$shackle_connector_timer.start(0.04)
		yield($shackle_connector_timer, "timeout")

