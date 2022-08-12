extends Bullet

var ff_player_position
var ff_counter = 0
var ff_focusing = false

func _ready():
	self.bullet_size = 18
	.colorize()
	pass

func _physics_process(delta):
	rotation = direction.angle() - 0.5 * PI
	if ff_focusing and ff_counter < 240:

		self.direction = self.direction.linear_interpolate(self.position.direction_to(ff_player_position), clamp(ff_counter * 0.0001, 0, 0.5))

		ff_counter += 1
		pass
	
