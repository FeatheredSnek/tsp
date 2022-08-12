extends Particles2D

var life_timer = 0

func _ready():
	emitting = true

func _physics_process(_delta):
	life_timer += 1
	if life_timer == 180:
		queue_free()
