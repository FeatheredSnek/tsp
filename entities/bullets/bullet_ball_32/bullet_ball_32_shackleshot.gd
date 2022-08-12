extends Bullet

var lifetime = int( 35 + randf() * 20 )

signal spawn_shackle(pos, dir)

func _ready():
	self.bullet_size = 32
	.colorize()

func _physics_process(delta):
	
	frame_counter += 1
	
	speed += acceleration
	position += direction.normalized() * speed * delta
	
	if frame_counter == lifetime:
		emit_signal("spawn_shackle", position, direction)
		emit_signal("request_clear_vfx", position, bullet_color, 2)
		queue_free()
	
	if position.x < -50 or position.x > 650 or position.y < -50 or position.x > 770:
		disconnect("spawn_shackle", get_parent(), "_on_bullet_spawn_shackle")
		set_physics_process(false)
		queue_free()


#func _on_bullet_VisibilityNotifier2D_viewport_exited(viewport):
#	disconnect("spawn_shackle", get_parent(), "_on_bullet_spawn_shackle")
#	set_process(false)
#	queue_free()

#extends Area2D
#
#var bullet_size = 32
#var bullet_color = 0
#var speed = 0
#var acceleration = 0
#var direction = Vector2.DOWN
#var viewport = get_viewport()
#
#enum {RED, GREEN, BLUE, GOLD, ORANGE, PURPLE}
#
#func _ready():
#	$bullet_sprite.region_rect.position.x = bullet_color * bullet_size
#	pass
#
#func _physics_process(delta):
#	speed += acceleration
#	position += direction.normalized() * speed * delta
#
#func _on_bullet_VisibilityNotifier2D_viewport_exited(viewport):
#	queue_free()



