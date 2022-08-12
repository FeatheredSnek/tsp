extends Attack

var bullet = preload("res://entities/bullets/bullet_arrow_16/bullet_arrow_16.tscn")
var powershot_bullet = preload("res://entities/bullets/bullet_arrow_24/bullet_arrow_24.tscn")

var colors = [Bullet.GOLD, Bullet.YELLOW]
var direction_offset = TAU / 3
var powershot_direction : Vector2 

func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.bonus_update_timer = $bonus_update_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()


# ---------- PATTERN ---------- 


func attack_cycle():
	$cycle_timer.start(1)
	yield($cycle_timer,"timeout")
	for i in range(19):
		powershot_single_shot()
		$cycle_timer.start(3)
		yield($cycle_timer,"timeout")


func powershot_single_shot():
	
	colors.invert()
	
	var target = Vector2()
	target.x = clamp((PlayerVars.position.x + 100 * rand_range(-1, 1)), 50, 550)
	if PlayerVars.position.y > 360:
		target.y = randf() * 100 + 50
	else:
		target.y = randf() * 100 + 50 + 360
	get_parent().get_node("windranger_unit").move_to(target, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$movement_timer.start(1)
	yield($movement_timer,"timeout")
	aim_powershot()



func aim_powershot():
	var powershot_direction_vector = (PlayerVars.position - boss_unit.position).normalized()
	var powershot_direction = powershot_direction_vector
	var powershot_target = boss_unit.position + powershot_direction_vector * 1200
	show_direction_indicator(boss_unit.position, PlayerVars.position)
	
	emit_signal("request_vfx", VfxServer.WR_LEAVES, boss_unit.position)
	emit_signal("request_sfx", SfxServer.BOSS_SPELL_GATHER)
	
	$powershot_delay_timer.start(1)
	yield($powershot_delay_timer, "timeout")
	
	boss_unit.animate_attack(false)
	
	$powershot_delay_timer.start(0.5)
	yield($powershot_delay_timer, "timeout")
	
	remove_offscreen_bullets()
	
	emit_signal("request_bloom_vfx", 0.3)
	emit_signal("request_sfx", SfxServer.BOSS_BLING)
	
	shoot_powershot_bullet(powershot_direction_vector)
	
	emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_1)
	
	$powershot_tween.interpolate_property($powershot_helper, "position",
			boss_unit.position, powershot_target, 0.6,
			Tween.TRANS_SINE, Tween.EASE_IN)
	$powershot_tween.start()



func show_direction_indicator(starting_position, direction):
	$powershot_direction_indicator.position = starting_position
	$powershot_direction_indicator.look_at(direction)
	$powershot_direction_indicator/indicator_animation.play("show")



func shoot_powershot_bullet(direction_vector):
	var bullet_to_add = powershot_bullet.instance()
	bullet_to_add.scale = Vector2(2,2)
	bullet_to_add.position = get_parent().get_node("windranger_unit").position
	bullet_to_add.direction = direction_vector
	bullet_to_add.speed = 900
	bullet_to_add.acceleration = 40
	bullet_to_add.add_to_group("EnemyBullets")
	add_child(bullet_to_add)
	pass



func _on_powershot_tween_tween_step(object, key, elapsed, value):

	var bullet_spawn_jitter = 5 - (randf() * 10)
	var bullet_spawn_position : Vector2 = Vector2(value.x + bullet_spawn_jitter, value.y + bullet_spawn_jitter)
	var random_direction = Vector2.ONE.rotated(TAU*randf())
	var perp = PI / 2
	
	var bullet_to_add = bullet.instance()
	bullet_to_add.position = bullet_spawn_position
	bullet_to_add.speed = 1
	bullet_to_add.acceleration = 0.1
	bullet_to_add.direction = random_direction
	bullet_to_add.bullet_color = colors[0]
	bullet_to_add.add_to_group("EnemyBullets")
	add_child(bullet_to_add)
	
	for j in range(1 + 2*PlayerVars.difficulty):
		for i in range(2):
			var bubu = bullet.instance()
			bubu.position = value
			bubu.speed = 15 + 50 * PlayerVars.difficulty + 20 * j
			bubu.acceleration = 0.1
			bubu.direction = (value - boss_unit.position).normalized().rotated(perp+PI*i)
			bubu.bullet_color = colors[1]
			bubu.add_to_group("EnemyBullets")
			add_child(bubu)

	emit_signal("request_shot_vfx", bullet_spawn_position, colors[0], 1)
	emit_signal("request_shot_vfx", value, colors[0], 1)
	emit_signal("request_vfx", VfxServer.WR_WIND, bullet_spawn_position)


