extends Attack

var spawning = false
var bullet_arrow_24 = preload("res://entities/bullets/bullet_arrow_24/bullet_arrow_24.tscn")

onready var positions = [$pos_1.position, $pos_2.position, $pos_3.position, $pos_4.position]

func _ready():
	self.attack_timer = $attack_timer
	self.countdown_timer = $countdown_timer
	self.cycle_timer = $cycle_timer
	self.bonus_update_timer = $bonus_update_timer
	self.boss_unit = get_parent().get_node("windranger_unit")
	self.connect_signals()


#-------------------- PATTERN -----------------------


func attack_cycle():
	yield(cycle_await(0.8),"timeout")
	emit_signal("request_vfx", VfxServer.WR_LEAVES, boss_unit.position)
	emit_signal("request_sfx", SfxServer.BOSS_SPELL_GATHER)
	yield(cycle_await(1.2),"timeout")
	boss_unit.animate_attack(false)
	yield(cycle_await(0.5),"timeout")
	spawning = true
	focusfire_bullet_spawner()
	random_mover()
	for i in range(12):
		yield(cycle_await(6.33),"timeout")
		#Vfx.wr_leaves(boss_unit.position)
		emit_signal("request_vfx", VfxServer.WR_LEAVES, boss_unit.position)
		emit_signal("request_sfx", SfxServer.BOSS_SPELL_GATHER)
		yield(cycle_await(1),"timeout")
		emit_signal("request_bloom_vfx", 1.0)
		emit_signal("request_sfx", SfxServer.BOSS_BLING)
		boss_unit.animate_attack(false)
		yield(cycle_await(0.66),"timeout")
		focusfire_bullets_direct()
	spawning = false


func random_mover():
	while spawning:
		boss_unit.move_to(positions[0], 6, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		positions.shuffle()
		$movement_timer.start(6)
		yield($movement_timer,"timeout")
	pass


func focusfire_bullet_spawner():
	
	var spawn_interval = 0.07 - 0.03*PlayerVars.difficulty
	var speed_jitter = 30
	var acceleration_jitter = 0.1
	var colors = [Bullet.GOLD, Bullet.YELLOW, Bullet.LIME]
	var speed_difficulty_factor = 25*PlayerVars.difficulty
	var spawn_sfx_counter = 0
	
	while spawning:
		
		colors.shuffle()
		var spawn_position = Vector2(600*randf(), (200*randf()-40))
		var bullet_to_add = bullet_arrow_24.instance()
		
		bullet_to_add.position = spawn_position
		bullet_to_add.direction = Vector2.DOWN
		bullet_to_add.speed = 60 + randf()*speed_jitter + speed_difficulty_factor
		bullet_to_add.acceleration = randf()*acceleration_jitter
		bullet_to_add.add_to_group("EnemyBullets")
		bullet_to_add.custom = true
		bullet_to_add.custom_type = "wr_focusfire"
		bullet_to_add.bullet_color = colors[0]
		add_child(bullet_to_add)
		
		emit_signal("request_shot_vfx", spawn_position,  colors[0], 1.3)
		
		if spawn_sfx_counter % 2 == 0:
			emit_signal("request_shot_sfx", SfxServer.ENEMY_SHOT_QUIET)
		spawn_sfx_counter += 1
		
		$arrow_spawn_timer.start(0.07)
		yield($arrow_spawn_timer,"timeout")



func focusfire_bullets_direct():
	
	var current_bullets = get_tree().get_nodes_in_group("EnemyBullets")

	for bullet in current_bullets:
		bullet.speed = bullet.speed * 0.1
		bullet.ff_player_position = PlayerVars.position
		bullet.ff_focusing = true
		bullet.acceleration += 1


func random_exploder():
	pass


#
