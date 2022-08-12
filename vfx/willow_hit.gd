extends Particles2D

func _ready():
	emitting = true

func _on_lifetime_timeout():
	queue_free()
