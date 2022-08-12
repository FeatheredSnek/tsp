extends Area2D

class_name Item

export (int) var speed

var framecount = 0
var is_homing = false
var direction = Vector2.DOWN
var item_type
onready var viewport = get_viewport()
onready var acceleration = Vector2(0,-8-2*randf())

enum {POINT, SHADOW, STAR, HEALTH}

func _ready():
	self.z_index = Global.CustomLayers.ITEMS


func _physics_process(delta):
	#	speed += acceleration
	position += direction * speed * delta + acceleration
	if acceleration.y < 0:
		acceleration.y += 0.1
	if is_homing:
		acceleration += direction * 0.1
		speed = 600
		var d = PlayerVars.position - position
		direction = d.normalized()


func set_homing():
	acceleration = Vector2.ZERO
	is_homing = true


func set_nonhoming():
	if item_type == 3:
		speed = 300
		for c in get_children():
			if c is Timer:
				c.stop()
	is_homing = false
	yield(get_tree(),"physics_frame")
	acceleration = Vector2(0,-8-2*randf())
	direction = Vector2.DOWN


func _on_item_visibility_viewport_exited(_viewport):
	if self.position.y > 730:
		queue_free()

