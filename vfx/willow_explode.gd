extends Node2D

var life_timer = 0

func _ready():
	$willow_explode_sprite.play("default")
	$willow_explode_particles.emitting = true

func _physics_process(_delta):
	life_timer += 1
	if life_timer == 150:
		queue_free()
