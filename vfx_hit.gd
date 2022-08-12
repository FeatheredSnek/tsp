extends Node2D

var life_timer = 0

func _ready():
	$flash_sprite.play("default")
	$blast_sprite.play("default")
	$hit_particles.emitting = true

func _physics_process(delta):
	life_timer += 1
	if life_timer > 60:
		queue_free()
