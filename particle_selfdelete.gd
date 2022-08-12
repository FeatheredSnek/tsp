extends Particles2D

var timer = 0

func _ready():
	emitting = true
#	yield(get_tree().create_timer(lifetime + 1,false),"timeout")
	

func _physics_process(delta):
	timer += 1
	if timer == 30:
		queue_free()

