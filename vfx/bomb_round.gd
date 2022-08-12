extends Node2D

var life_timer = 0

func _ready():
	$ring_sprite.play("default")
	$smoke.emitting = true

func _physics_process(_delta):
	life_timer += 1
	if life_timer == 60:
		queue_free()
