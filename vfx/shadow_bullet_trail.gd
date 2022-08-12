extends Node2D

var bullet_to_track
var is_tracking = false
var bullet_id
var prevpos = Vector2(0,0)
var life_timer = 0

func _ready():
	pass


func _physics_process(delta):
	
	if is_instance_valid(bullet_to_track):
		if bullet_to_track.get_instance_id() == bullet_id:
			position = bullet_to_track.position
			prevpos = position
	else:
		position = prevpos
	
	life_timer += 1
	if life_timer > 120:
		$trail_particles.emitting = false
	if life_timer > 160:
		queue_free()


func track(bullet):
	is_tracking = true
	bullet_to_track = bullet
	bullet_id = bullet.get_instance_id()


func _on_stop_emitting_particles():
	$trail_particles.emitting = false
