extends Particles2D

var life_time = 0

func _physics_process(_delta):
	life_time += 1
	if life_time == 80:
		queue_free()
