extends Bullet

func _ready():
	self.bullet_size = 32
	.colorize()
	pass

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



