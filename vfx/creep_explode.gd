extends Node2D

var life_timer = 0

func _ready():
	$creep_explode_sprite.play("default")
	$creep_explode_particles.emitting = true

func _physics_process(_delta):
	life_timer += 1
	if life_timer == 180:
		queue_free()
