extends Area2D

export (int) var speed = 600
export (int) var acceleration = 0
export (int) var player_bullet_damage = 5

var direction = Vector2.UP
var viewport = get_viewport()
var counter = 1

onready var mod = 90 + int(randf() * 20)
onready var direction_mod = 0.1 + randf() * 0.1
onready var fract = 1.0 / mod
onready var init_sign = 1 - 2*round(randf()) #1 - ( 2 * ( 3 % (1+int(2*randf())) ) )


signal stop_emitting_particles
signal request_vfx(type, pos)


func _ready():
	connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
	self.z_index = Global.CustomLayers.PLAYER_BULLET


func _physics_process(delta):
	direction = Vector2.UP.rotated(((cos(TAU * ((1.0/mod) * counter))) * direction_mod) * init_sign)
	
	speed += acceleration
	rotation = direction.angle() + PI/2
	position += direction.normalized() * speed * delta
	
	counter += 1
	if counter == mod:
		counter = 1


func _on_player_bullet_visibility_notifier_viewport_exited(viewport):
	emit_signal("stop_emitting_particles")
	queue_free()


func _on_player_bullet_shadow_area_entered(area):
	emit_signal("stop_emitting_particles")
	emit_signal("request_vfx", VfxServer.SHADOW_HIT_EXPLODE, position)
	
	queue_free()
