extends Area2D

class_name Bullet

var bullet_size = 0
var bullet_color = 0
var speed = 0
var acceleration = 0
var direction = Vector2.DOWN
var custom = false
var frame_counter = 0
var init_speed = 0
var init_dir
var init_direction
var init_acceleration
var max_speed = 0
var min_speed
var custom_type
var t1
var noexit = false

signal bullet_cleared(bullet_position)
signal request_clear_vfx(pos, col, scl)


enum {RED, GREEN, BLUE, YELLOW, GOLD, CYAN, LIME, PURPLE}


func _ready():
	self.monitoring = false
	connect("bullet_cleared", Global.current_game_viewport, "_on_bullet_cleared")
	connect("request_clear_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "bullet_clear_vfx")
	if custom:
		init_speed = speed
		init_direction = direction
		init_acceleration = acceleration
	self.z_index = Global.CustomLayers.BULLETS


func colorize():
	self.get_node("bullet_sprite").region_rect.position.x = self.bullet_color * self.bullet_size


func _physics_process(delta):
	if custom:
		custom_movement()
	speed += acceleration
	position += direction.normalized() * speed * delta
	if min_speed is int:
		speed = clamp(speed, min_speed, max_speed)


func step_rotate_towards_target(duration : float, steps : int, angle_to_target : float):
	var angle_factor = angle_to_target / steps
	var step_time = duration / steps
	for i in range(steps):
		direction = Vector2.DOWN.rotated(angle_factor * i)
		yield(get_tree().create_timer(step_time, false),"timeout")
	pass


func custom_movement():
	frame_counter += 1
	
	match custom_type:
		"wr_1":
			direction = direction.rotated(0.36 / frame_counter)
			acceleration = -5
			speed = clamp(speed, -100, 300)			
		"wr_2_stream":
			if frame_counter < 114:
				direction = direction.rotated(0.0012*clamp(frame_counter, 0, 60))
			else:
				direction = direction.rotated(0.012)
		"wr_3_explode":
			if frame_counter < 200:
				direction = direction.rotated(t1 * 0.3 / frame_counter)
		"wr_3_explode_2":
			if frame_counter < 300:
				direction = direction.rotated(t1 * 0.4 / frame_counter)
			speed = clamp(speed, min_speed, max_speed)
		"wr_3_bigball_explode":
			speed = clamp(speed, 0, max_speed)
		"shackle_directed":
			direction = (PlayerVars.position - position).normalized()
		"wr_windrun_stream":
			pass
		"wr_focusfire":
			pass
		"wr_shackle":
			if frame_counter == 180:
				acceleration = 5
		"wr_shackle_arrow":
			if frame_counter == 100:
				acceleration = 0.8
		_:
			pass
	pass

func clear():
	emit_signal("bullet_cleared", position)
	emit_signal("request_clear_vfx", position, bullet_color, ( 1 + ( bullet_size - 8)*0.025 ) )
	queue_free()

func _on_bullet_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()
