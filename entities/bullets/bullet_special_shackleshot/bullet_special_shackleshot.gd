extends Node2D

signal connect_shackles(pos_a, pos_b, col)

var direction = Vector2.DOWN
var starting_speed = 10
var speed = 0
var acceleration = -2.1
var pair_color = 0

var starting_angular_speed = TAU/60
var angular_speed = 0
var angular_acceleration = 0

var counter = 0
var bullets_visible = true


func _ready():
	
	speed = starting_speed 
	angular_speed = starting_angular_speed
	angular_acceleration = starting_angular_speed / 180 * -1
	rotation += 10
	
	$bullet_ball_32_a.get_children()[1].disconnect("viewport_exited", $bullet_ball_32_a, "_on_bullet_VisibilityNotifier2D_viewport_exited")
	$bullet_ball_32_b.get_children()[1].disconnect("viewport_exited", $bullet_ball_32_b, "_on_bullet_VisibilityNotifier2D_viewport_exited")
	
	var starting_direction = Vector2.LEFT
	
	$bullet_ball_32_a.speed = 60 + 12*PlayerVars.difficulty
	$bullet_ball_32_a.direction = Vector2.LEFT
	$bullet_ball_32_a.acceleration = -0.4
	$bullet_ball_32_a.min_speed = 0
	$bullet_ball_32_a.max_speed = 90
	
	$bullet_ball_32_b.speed = 60 + 12*PlayerVars.difficulty
	$bullet_ball_32_b.direction = Vector2.RIGHT
	$bullet_ball_32_b.acceleration = -0.4
	$bullet_ball_32_b.min_speed = 0
	$bullet_ball_32_b.max_speed = 90
	
	$bullet_ball_32_a.bullet_color = pair_color
	$bullet_ball_32_b.bullet_color = pair_color
	$bullet_ball_32_a.colorize()
	$bullet_ball_32_b.colorize()


func _physics_process(delta):

	acceleration -= 0.001
	speed += acceleration
	position += direction.normalized() * clamp(speed, 0, starting_speed) * delta	

	angular_speed += angular_acceleration
	angular_speed = clamp(angular_speed, 0, TAU)
	rotation += angular_speed
#
#	if counter < 190:
	counter += 1
	
	if counter == 188:
		for child in get_children():
			child.emit_signal("request_clear_vfx", child.global_position, 0, 2)
		if get_children().size() > 1:
			emit_signal("connect_shackles", $bullet_ball_32_a.global_position, $bullet_ball_32_b.global_position, pair_color)
		queue_free()
	
