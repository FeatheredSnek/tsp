extends Node2D


export (int) var speed_default = 500
export (int) var speed_focused = 100
export (int) var grace_frames = 15
export (int) var invu_frames = 60
export (bool) var is_invunerable = false


var origin = Vector2()
var movement
var speed = speed_default
var viewport_size
var fire_counter = 0
var clampvector
var bomb_on_cooldown = false
var player_disabled_controls= false
var shadow_gauge_full = true
var is_in_shadow_realm = false
var is_focused = false
var shot_angle = 0.5

var is_shooting = false
var is_moving = {"up":false,"down":false,"left":false,"right":false}
var is_stopped = true

var player_bullet = preload("res://entities/player/player_bullet.tscn")
var player_bullet_shadow = preload("res://entities/player/player_bullet_shadow.tscn")
var player_bomb_bullet = preload("res://entities/player/jex_bullet.tscn")

signal hit
signal hit_by_spell(spell_data)
signal bomb_away
signal player_graze
signal update_shadow
signal update_hearts
signal update_bombs
signal player_dead
signal shadow_entered
signal shadow_exited
#signal hide_gauge(shoud_be_hidden)

signal request_vfx(type, pos)
signal vfx_points(value, pos, txtcolor)
signal vfx_track_bullet(bullet)
signal request_sfx(type)
#	point_number(value:int, pos:Vector2, txtcolor:Color):

var leashed = {"status": false, "radius": 0, "leash_point": Vector2()}

var status_list = []


func _ready():
	
	connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
	connect("vfx_points", get_tree().get_nodes_in_group("VfxServers")[0], "point_number")
	connect("vfx_track_bullet", get_tree().get_nodes_in_group("VfxServers")[0], "shadow_bullet_trail_vfx")
	connect("request_sfx", get_viewport(), "sfx_request")
	
	viewport_size = get_viewport_rect().size
	$hitbox_sprite.hide()
	origin = Vector2(0,0)
	movement = Vector2(0,0)
	
	$willow_sprite_body.z_index = Global.CustomLayers.PLAYER_SPRITE
	$hitbox_sprite.z_index = Global.CustomLayers.PLAYER_HITBOX
	$player_seal.z_index = Global.CustomLayers.PLAYER_SEAL
	$bomb_projectile_path/bomb_projectile_path_follower/jex.z_index = Global.CustomLayers.PLAYER_BULLET



func _physics_process(delta):
	
	var vel = input_movement()
	position += vel * delta
	position.x = clamp(position.x, 0, viewport_size.x)
	position.y = clamp(position.y, 0, viewport_size.y - 4)

#	if leashed.status == true:
#		var clampvector = position.direction_to(leashed.leash_point)
#		clampvector = clampvector * leashed.radius
#		position.x = clamp(position.x, leashed.leash_point.x-clampvector.abs().x, leashed.leash_point.x+clampvector.abs().x)
#		position.y = clamp(position.y, leashed.leash_point.y-clampvector.abs().y, leashed.leash_point.y+clampvector.abs().y)
#		pass
	
	fire_counter += 1
	input_fire(fire_counter)
	if fire_counter > 60:
		fire_counter = 0
	
	PlayerVars.position = position



func input_movement():
	
	var velocity = Vector2()  
	
	if player_disabled_controls== false:
		
		if Input.is_action_pressed("ui_custom_focus"):
			speed = speed_focused
			$hitbox_sprite.show()
			shot_angle = 0.2
		else:
			speed = speed_default
			$hitbox_sprite.hide()
			shot_angle = 0.5
			
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		
	return velocity



func input_fire(counter):
	#NORMAL SHOT
	if player_disabled_controls == false and Input.is_action_pressed("ui_custom_fire") and not is_in_shadow_realm and counter % 10 == 0:
#	if player_disabled_controls == false and not is_in_shadow_realm and counter % 10 == 0:
		emit_signal("request_sfx", SfxServer.PLAYER_SHOT)
		var bullet_to_add = player_bullet.instance()
		bullet_to_add.position = position + $player_shoot_from.position
		get_parent().add_child(bullet_to_add)
		#sideways shots
		var bullet_right = player_bullet.instance()
		bullet_right.position = position + $player_shoot_from.position
		bullet_right.direction = Vector2.UP.rotated(shot_angle)
		get_parent().add_child(bullet_right)
		var bullet_left = player_bullet.instance()
		bullet_left.position = position + $player_shoot_from.position
		bullet_left.direction = Vector2.UP.rotated(-1 * shot_angle)
		get_parent().add_child(bullet_left)
	#SHADOW REALM SHOT
	if player_disabled_controls== false and Input.is_action_pressed("ui_custom_fire") and is_in_shadow_realm and counter % 30 == 0:
		emit_signal("request_sfx", SfxServer.PLAYER_SHOT_SHADOW)
		var bullet_to_add = player_bullet_shadow.instance()
		bullet_to_add.position = position + $player_shoot_from.position
		get_parent().add_child(bullet_to_add)
		emit_signal("vfx_track_bullet", bullet_to_add)



func _input(event):
	if not player_disabled_controls:
		#BOMBS
		if event.is_action_pressed("ui_custom_bomb") and bomb_on_cooldown == false:
			if PlayerVars.bombs > 0:
				bomb()
		if event.is_action_pressed("ui_custom_shadow") and PlayerVars.shadow_gauge_value >= PlayerVars.shadow_gauge_treshold and not is_in_shadow_realm:
			enter_shadow_realm()
		#MOVEMENT ANIMATIONS
			#PRESS
		if event.is_action_pressed("ui_up"):
			$willow_sprite_body/willow_animation_general.play("willow_forward")
			is_moving.up = true
		if event.is_action_pressed("ui_down"):
			$willow_sprite_body/willow_animation_general.play("willow_back")
			is_moving.down = true
		if event.is_action_pressed("ui_left"):
			$willow_sprite_body/willow_animation_general.play("willow_turn_left")
			is_moving.left = true
		if event.is_action_pressed("ui_right"):
			$willow_sprite_body/willow_animation_general.play("willow_turn_right")
			is_moving.right = true
			#RELEASE
		if event.is_action_released("ui_up"):
			is_moving.up = false
			if not is_moving.up and not is_moving.down and not is_moving.right and not is_moving.left:
				$willow_sprite_body/willow_animation_general.play("willow_idle")
		if event.is_action_released("ui_down"):
			is_moving.down = false
			if not is_moving.up and not is_moving.down and not is_moving.right and not is_moving.left:
				$willow_sprite_body/willow_animation_general.play("willow_idle")
		if event.is_action_released("ui_left"):
			is_moving.left = false
			if not is_moving.up and not is_moving.down and not is_moving.right and not is_moving.left:
				$willow_sprite_body/willow_animation_general.play("willow_idle")
		if event.is_action_released("ui_right"):
			is_moving.right = false
			if not is_moving.up and not is_moving.down and not is_moving.right and not is_moving.left:
				$willow_sprite_body/willow_animation_general.play("willow_idle")
		#ATTACK ANIMATIONS
		if event.is_action_pressed("ui_custom_fire"):
			$willow_sprite_body/willow_animation_attack.play("willow_attack_start")
		if event.is_action_released("ui_custom_fire"):
			$willow_sprite_body/willow_animation_attack.play_backwards("willow_attack_start")
		#SEAL ANIMATIONS
		if event.is_action_pressed("ui_custom_focus"):
			$player_seal_shower.play("player_seal_show")
		if event.is_action_released("ui_custom_focus"):
			$player_seal_shower.play_backwards("player_seal_show")


func player_disable_controls():
	player_disabled_controls= true

func player_enable_controls():
	player_disabled_controls= false

func player_toggle_controls():
	player_disabled_controls = !player_disabled_controls


func bomb():
	PlayerVars.bombs -= 1
	emit_signal("bomb_away")
	emit_signal("update_bombs")
	bomb_on_cooldown = true
	# sfx
	emit_signal("request_sfx", SfxServer.PLAYER_BOMB)
	# vfx
	emit_signal("request_vfx", VfxServer.BOMB, position)
	$jex_appear.play("default")
	$jex_appear_smoke.emitting = true
	# jex's movement
	var bullets_in_area = $bomb_area.get_overlapping_areas()
	var jex = $bomb_projectile_path/bomb_projectile_path_follower/jex
	var move_tween = $move_tween
	var bomb_time = 4
	for b in bullets_in_area:
		if b.is_in_group("EnemyBullets"):
			b.clear()
	jex.visible = true
	move_tween.interpolate_property($bomb_projectile_path/bomb_projectile_path_follower, "unit_offset", 0, 1, bomb_time, Tween.TRANS_LINEAR)
	move_tween.start()
	$bomb_projectile_path/bomb_shooter_timer.start()
	yield(move_tween,"tween_all_completed")
	$bomb_projectile_path/bomb_shooter_timer.stop()
	$jex_appear.frame = 0
	$jex_appear.play("default")
#	yield(get_tree().create_timer(0.02, false), "timeout")
	yield($jex_appear,"animation_finished")
	jex.visible = false
	$bomb_cooldown_timer.start()
	yield($bomb_cooldown_timer, "timeout")
	bomb_on_cooldown = false


func _on_bomb_shooter_timer_timeout():
	var bullet_to_add = player_bomb_bullet.instance()
	bullet_to_add.position = $bomb_projectile_path/bomb_projectile_path_follower/jex.global_position
	bullet_to_add.speed += 100 * randf()
	bullet_to_add.direction = Vector2.ONE.rotated(TAU * randf())
	get_parent().add_child(bullet_to_add)


func enter_shadow_realm():
	PlayerVars.shadow_gauge_value = 0
	PlayerVars.shadow_status = true
	emit_signal("update_shadow")
	emit_signal("shadow_entered")
	is_in_shadow_realm = true
	$shadow_realm_timer.start()
	# sfx
	emit_signal("request_sfx", SfxServer.PLAYER_ENTER_SHADOWREALM)
	# vfx
	$shadow_enter_explode.visible = true
	$shadow_enter_explode.play("default")
	$shadow_particles_enter.emitting = true
	$shadow_particles_cyan.emitting = true
	$shadow_particles_pink.emitting = true
	$willow_sprite_body.modulate = Color(0, 0.24, 0.31)
	$shadow_seal_collapse.play("shadow_seal_collapse")
	$shadow_seal_rotator.rotation_degrees = $player_seal/player_seal_inner.rotation_degrees


func exit_shadow_realm():
	PlayerVars.shadow_status = false
	is_in_shadow_realm = false
	$shadow_realm_timer.stop()
	$shadow_realm_timer.wait_time = 5
	emit_signal("shadow_exited")
	# sfx
	emit_signal("request_sfx", SfxServer.PLAYER_EXIT_SHADOWREALM)
	# vfx
	$shadow_enter_explode.visible = false
	$shadow_exit_explode.visible = true
	$shadow_exit_explode.play("default")
	$shadow_particles_enter.emitting = false
	$shadow_particles_enter.emitting = true
	$shadow_particles_cyan.emitting = false
	$shadow_particles_pink.emitting = false
	$willow_sprite_body.modulate = Color.white


func leash(r, duration):
	leashed.status = true
	leashed.leash_point = position
	leashed.radius = r
	$status_timer.wait_time = duration
	$status_timer.start()


func _on_status_timer_timeout():
	remove_status()


func remove_status():
	leashed.status = false


func _on_hitbox_area_area_entered(area):
	match area.collision_layer:
		1, 8:
			player_hit()
			if area is Bullet:
				area.clear()
		16:
			emit_signal("hit_by_spell", area.spell_data)


func player_hit():
	if is_invunerable:
		# hit while invunerable
		return
	else:
		# hit while vunerable
		is_invunerable = true
		if not is_in_shadow_realm:
			emit_signal("request_sfx", SfxServer.PLAYER_GET_HIT)
			var bomby = PlayerVars.bombs
			$hitbox_area.set_deferred("monitoring", false)
			for f in range(grace_frames):
				yield(get_tree(),"physics_frame")
			if PlayerVars.bombs == bomby:
				# hit - lost hp
				emit_signal("hit")
				if PlayerVars.hp > 1:
					# reduce hp
					PlayerVars.hp -= 1
					PlayerVars.shadow_gauge_value = int(PlayerVars.shadow_gauge_value / 2)
					emit_signal("update_shadow")
					emit_signal("update_hearts")
					emit_signal("request_vfx", VfxServer.WILLOW_HIT, position)
					$player_hit_animation.play("player_hit_blinking", -1, 2)
					for f in range(invu_frames):
						yield(get_tree(),"physics_frame")
					$hitbox_area.monitoring = true
					is_invunerable = false
					return
				else:
					# kill player
					PlayerVars.hp -= 1
					emit_signal("update_hearts")
					emit_signal("player_dead")
					emit_signal("request_vfx", VfxServer.WILLOW_EXPLODE, position)
					if bomb_on_cooldown:
						$move_tween.stop_all()
						$bomb_projectile_path/bomb_shooter_timer.stop()
						emit_signal("request_vfx", VfxServer.JEX_EXPLODE, $bomb_projectile_path/bomb_projectile_path_follower/jex.position)
					queue_free()
					return
			else:
				# saved - bombed in grace frames
				yield(get_tree(),"physics_frame")
				is_invunerable = false
				$hitbox_area.monitoring = true
				return
		else:
			# saved - hit in shadow realm
			yield(get_tree(),"physics_frame")
			exit_shadow_realm()
			for l in range(10):
				yield(get_tree(),"physics_frame")
			is_invunerable = false
			$hitbox_area.monitoring = true
			return



func _on_player_hit():
	pass



func _on_player_hit_by_spell(spell_data):
	match spell_data:
		{"spell_type" : "leash", ..}:
#			leash(spell_data.leash_radius, spell_data.leash_duration)
			return
		{"spell_type" : "stun", ..}:
			return



func _on_graze_area_area_entered(_area):
	emit_signal("request_sfx", SfxServer.PLAYER_GRAZE)
	PlayerVars.graze += 1
	PlayerVars.score += PlayerVars.graze_score
	if is_in_shadow_realm:
		PlayerVars.v_mult += PlayerVars.graze_plus_v_mult
	else:
		PlayerVars.s_mult += PlayerVars.graze_plus_s_mult
	emit_signal("player_graze")



func height_scoring_factor(player_y, is_item_homing):
	if is_item_homing:
		return 1.0
	else:
		return player_y / 720.0 * 0.5



func _on_collect_area_area_entered(area):
	
	emit_signal("request_sfx", SfxServer.PLAYER_COLLECT)

	match area.item_type:
		1:
			var height_factor = height_scoring_factor(position.y, area.is_homing)
			var score = int((PlayerVars.p_item_base_score*(1+PlayerVars.difficulty)) * PlayerVars.v_mult * height_factor)
			PlayerVars.score += score
			if height_factor == 1.0:
				emit_signal("vfx_points", score, area.position, Color.yellow)
			else:
				emit_signal("vfx_points", score, area.position, Color.white)
		2:
			PlayerVars.score += PlayerVars.s_item_base_score
			emit_signal("vfx_points", int(PlayerVars.s_item_base_score), area.position, Color.white)
			if PlayerVars.shadow_gauge_value < PlayerVars.shadow_gauge_treshold:
				PlayerVars.shadow_gauge_value = int(clamp( PlayerVars.shadow_gauge_value + (PlayerVars.s_item_base_gauge * PlayerVars.s_mult), 0, PlayerVars.shadow_gauge_treshold ))
				emit_signal("update_shadow")
		3:
			PlayerVars.score += PlayerVars.bullet_item_base_score
			emit_signal("vfx_points", PlayerVars.bullet_item_base_score, area.position, Color(1.0,1.0,1.0,0.33))
#	yield(get_tree(),"idle_frame")
	area.queue_free()


func _on_shadow_realm_timer_timeout():
	exit_shadow_realm()
