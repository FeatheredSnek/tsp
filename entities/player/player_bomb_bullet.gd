
extends Area2D

export (int) var speed 
export (int) var acceleration
export (int) var player_bullet_damage = 4

var direction = Vector2.UP
var viewport = get_viewport()
var lifetime_frame_counter = 0

signal request_vfx(type, pos)

func _ready():
	self.z_index = Global.CustomLayers.PLAYER_BULLET
	connect("request_vfx", get_tree().get_nodes_in_group("VfxServers")[0], "add_vfx")

func _physics_process(delta):
	speed += acceleration
	rotation = direction.angle()
	position += direction.normalized() * speed * delta
	lifetime_frame_counter += 1
	if lifetime_frame_counter > 20:
#		Vfx.jex_hit_explode_vfx(position)
		queue_free()

func _on_player_bomb_bullet_visibility_notifier_viewport_exited(viewport):
	queue_free()

func _on_jex_bullet_area_entered(area):
	emit_signal("request_vfx", VfxServer.JEX_HIT, position)
	#Vfx.jex_hit_explode_vfx(position)
	queue_free()
