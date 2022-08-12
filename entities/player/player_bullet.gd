extends Area2D

export (int) var speed = 600
export (int) var acceleration = 0
export (int) var player_bullet_damage = 1

var scale_factor = 0.5
var direction = Vector2.UP
var viewport = get_viewport()
#signal request_vfx(type, pos)
#
#var counter = 0
#
#func _ready():
#	#vw_ready = get_viewport()
#	connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
#	connect("request_shot_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "shot_vfx")
##	shot_vfx(pos:Vector2, col:int, scl:float):
#	pass

signal request_vfx(type, pos)
signal request_sfx(type)

func _ready():
#	scale.x = 0.2
#	scale.y = 0.2
	connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")
	$player_bullet_animated.play("default")
	$player_bullet_trail.emitting = true
	self.z_index = Global.CustomLayers.PLAYER_BULLET
	pass
#
#func grow():
#	var steps = 10
#	var step_val = 0.8 / steps
#	for i in range(steps):
#		scale.x += step_val
#		scale.y += step_val
#		yield(get_tree(),"physics_frame")
	
func _physics_process(delta):
	speed += acceleration
	rotation = direction.angle() + 0.5 * PI
	position += direction.normalized() * speed * delta

func _on_player_bullet_visibility_notifier_viewport_exited(viewport):
	queue_free()

func _on_player_bullet_area_entered(area):
	emit_signal("request_vfx", VfxServer.HIT, position)
	emit_signal("request_sfx", SfxServer.PLAYER_BULLET_HIT_SHADOWREALM)
#	Vfx.hit_explode_vfx(position)
	queue_free()
