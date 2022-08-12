extends Attack

var is_streaming = false
var sync_movements = false

var bullet_arrow = preload("res://entities/bullets/bullet_arrow_16/bullet_arrow_16.tscn")
var bullet_ball_bordered = preload("res://entities/bullets/bullet_bordered_32/bullet_bordered_32.tscn")

var movement_skip_counter = 0

func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.bonus_update_timer = $bonus_update_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()


#--------------- PATTERN --------------


func attack_cycle():
	
	boss_unit.move_to($movement_path.curve.get_point_position(0), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	yield(cycle_await(0.4),"timeout")
	emit_signal("request_vfx", VfxServer.WR_LEAVES, boss_unit.position)
	emit_signal("request_sfx", SfxServer.BOSS_SPELL_GATHER)
	#Vfx.wr_leaves(boss_unit.position)
	yield(cycle_await(1.6),"timeout")
	#Vfx.quick_bling()
	emit_signal("request_bloom_vfx", 0.3)
	boss_unit.animate_attack(true)
	windrun_movement()
	is_streaming = true
	yield(cycle_await(0.1),"timeout")
	windrun_streams()
	yield(cycle_await(1.5),"timeout")
	windrun_explodes()
	yield(cycle_await(60),"timeout")
	is_streaming = false
	yield(cycle_await(1),"timeout")
	sync_movements = false



func _physics_process(delta):
	if sync_movements:
		boss_unit.position = $movement_path/movement_path_follow/follower_position.global_position
	pass


func windrun_movement():
	$movement_tween.interpolate_property($movement_path/movement_path_follow, "unit_offset", 0, 2, 60, Tween.TRANS_LINEAR)
	$movement_tween.start()
	sync_movements = true
	pass


func _on_movement_tween_tween_step(object, key, elapsed, value):
	emit_signal("request_vfx", VfxServer.WR_WIND, boss_unit.position)



func windrun_streams():
	
	var stream_count = 4 + 2*PlayerVars.difficulty
	var substream_count = 2
	var stream_rotation_factor = TAU / stream_count
	var mini_rotation_factor = 0.25 - 0.1*PlayerVars.difficulty
	var wr_pos
	var player_pos
	var direction_vector
	
	while is_streaming:
		
		for i in range(stream_count):
			
			for j in range(substream_count):
				wr_pos = boss_unit.position
				player_pos = PlayerVars.position
				direction_vector = (player_pos - wr_pos).normalized()
				var bullet_to_add = bullet_arrow.instance()
				bullet_to_add.position = get_parent().get_node("windranger_unit").position
				bullet_to_add.speed = 450
				bullet_to_add.direction = direction_vector.rotated( (stream_rotation_factor * i) + (mini_rotation_factor * (1-2*j)) )
				bullet_to_add.add_to_group("EnemyBullets")
				bullet_to_add.custom = true
				bullet_to_add.custom_type = "wr_windrun_stream"
				if j == 1:
					bullet_to_add.bullet_color = Bullet.GOLD
				else:
					bullet_to_add.bullet_color = Bullet.YELLOW
				add_child(bullet_to_add)
				
		
		emit_signal("request_shot_vfx", boss_unit.position, Bullet.YELLOW, 1.0)
		emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_QUIET)
		
		$stream_spawn_timer.start(0.1)
		yield($stream_spawn_timer,"timeout") #0.1



func windrun_explodes():
	
	var single_explode_count = 10
	var rotation_factor = TAU / single_explode_count
	var init_speed = 250 + 120*PlayerVars.difficulty
	var time_between_explosions = 4 - 1*PlayerVars.difficulty
	var colors = [Bullet.BLUE, Bullet.CYAN]
	
	while is_streaming:
		
		for i in range(single_explode_count):
			var bullet_to_add = bullet_ball_bordered.instance()
			bullet_to_add.position = get_parent().get_node("windranger_unit").position
			bullet_to_add.speed = init_speed + randf() * 200
			bullet_to_add.direction = Vector2.DOWN.rotated(rotation_factor * i)
			bullet_to_add.add_to_group("EnemyBullets")
			bullet_to_add.custom = false
			bullet_to_add.min_speed = 40
			bullet_to_add.max_speed = 600
			bullet_to_add.acceleration = -15
			bullet_to_add.bullet_color = colors[0]
			add_child(bullet_to_add)
		
		emit_signal("request_shot_vfx", boss_unit.position, colors[0], 1.6)
		colors.invert()
		
		emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_2)
		
		$explode_timer.start(time_between_explosions)
		yield($explode_timer,"timeout") #0.1
