extends AnimatedSprite

func _ready():
	play("default")
	pass

func _on_animation_finished():
	queue_free()
