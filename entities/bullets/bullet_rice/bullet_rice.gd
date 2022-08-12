extends Bullet

func _ready():
	self.bullet_size = 8
	.colorize()
	pass

func _physics_process(delta):
	rotation = direction.angle() - 0.5 * PI
