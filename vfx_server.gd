extends Node2D

class_name VfxServer

var current_viewport
var current_viewport_container
var current_viewport_background

var shot_sprite = preload("res://vfx/shot.tscn")
var bullet_explode_sprite = preload("res://vfx/bullet_explode.tscn")
var creep_explode_node = preload("res://vfx/creep_explode.tscn")
var hit_explode_node = preload("res://vfx/hit_explode.tscn")
var shadow_bullet_trail_node = preload("res://vfx/shadow_bullet_trail.tscn")
var shadow_hit_explode_node = preload("res://vfx/shadow_hit_explode.tscn")
var jex_hit_explode_node = preload("res://vfx/jex_hit_explode.tscn")
var bomb_round_node = preload("res://vfx/bomb_round.tscn")
var ui_explode_heart_node = preload("res://vfx/ui_explode_heart.tscn")
var ui_explode_bomb_node = preload("res://vfx/ui_explode_bomb.tscn")
var wr_gather_node = preload("res://vfx/wr_gather_particles.tscn")
var sc_gather_node = preload("res://vfx/sc_gather_particles.tscn")
var wr_wind_node = preload("res://vfx/wr_powershot_particles.tscn")
var willow_explode_node = preload("res://vfx/willow_explode.tscn")
var wr_leaves_node = preload("res://vfx/wr_gather_leaves.tscn")
var point_number_node = preload("res://vfx/point_number.tscn")
var willow_hit_node = preload("res://vfx/willow_hit.tscn")

var shader_default = load("res://vfx/shaders/shader_default.tres")
var shader_red = load("res://vfx/shaders/shader_red.tres")
var shader_green = load("res://vfx/shaders/shader_green.tres")
var shader_blue = load("res://vfx/shaders/shader_blue.tres")
var shader_gold = load("res://vfx/shaders/shader_gold.tres")

enum {RED, GREEN, BLUE, YELLOW, GOLD, CYAN, LIME, PURPLE}
enum {HIT, JEX_HIT, CREEP_MEELE_EXPLODE, CREEP_RANGED_EXPLODE, SHADOW_HIT_EXPLODE, BOMB, WILLOW_HIT, WILLOW_EXPLODE, JEX_EXPLODE, WR_GATHER, WR_WIND, WR_LEAVES, SC_GATHER, WR_ATTACK_END_EXP}
enum {OUTWARD, INWARD}


func _ready():
	current_viewport = get_parent()
	current_viewport_container = get_parent().get_parent()
	current_viewport_background = get_parent().get_child(0)


func shot_vfx(pos:Vector2, col:int, scl:float):
	var vfx_sprite = shot_sprite.instance()
	vfx_sprite.position = pos
	vfx_sprite.scale *= scl
	vfx_sprite.z_index = Global.CustomLayers.VFX
	match col:
		RED:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.6, 1.1, 1.1 ))
		GREEN, LIME:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.7, 0.9 ))
		BLUE:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.1, 1.6 ))
		CYAN:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.4, 1.5 ))
		YELLOW, GOLD:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.4, 1.3, 0.9 ))
		PURPLE:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.2, 0.9, 1.4 ))
	current_viewport.add_child(vfx_sprite)


func bullet_clear_vfx(pos:Vector2, col:int, scl:int):
	var vfx_sprite = bullet_explode_sprite.instance()
	vfx_sprite.position = pos
	vfx_sprite.scale *= scl
	vfx_sprite.z_index = Global.CustomLayers.VFX
	match col:
		RED:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.6, 1.1, 1.1 ))
		GREEN, LIME:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.7, 0.9 ))
		BLUE:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.1, 1.6 ))
		CYAN:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 0.9, 1.4, 1.5 ))
		YELLOW, GOLD:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.4, 1.3, 0.9 ))
		PURPLE:
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.2, 0.9, 1.4 ))
	current_viewport.add_child(vfx_sprite)


func add_vfx(type:int, pos:Vector2):
	var vfx_sprite
	match type:
		HIT:
			vfx_sprite = hit_explode_node.instance()
		JEX_HIT:
			vfx_sprite = jex_hit_explode_node.instance()
		CREEP_MEELE_EXPLODE:
			vfx_sprite = creep_explode_node.instance()
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.0, 1.5, 2.5 ))
		CREEP_RANGED_EXPLODE:
			vfx_sprite = creep_explode_node.instance()
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 2.2, 2.0, 1.0 ))
		SHADOW_HIT_EXPLODE:
			vfx_sprite = shadow_hit_explode_node.instance()
		BOMB:
			vfx_sprite = bomb_round_node.instance()
		JEX_EXPLODE:
			vfx_sprite = jex_hit_explode_node.instance()
		WILLOW_HIT:
			vfx_sprite = willow_hit_node.instance()
		WILLOW_EXPLODE:
			vfx_sprite = willow_explode_node.instance()
		WR_GATHER:
			vfx_sprite = wr_gather_node.instance()
		WR_LEAVES:
			vfx_sprite = wr_leaves_node.instance()
		WR_WIND:
			vfx_sprite = wr_wind_node.instance()
		SC_GATHER:
			vfx_sprite = sc_gather_node.instance()
		WR_ATTACK_END_EXP:
			vfx_sprite = creep_explode_node.instance()
			vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.0, 2.5, 1.5 ))
			vfx_sprite.scale *= 2.5
	if vfx_sprite is Node:
		vfx_sprite.position = pos
		vfx_sprite.z_index = Global.CustomLayers.VFX
		current_viewport.add_child(vfx_sprite)


func shadow_bullet_trail_vfx(bullet):
	var vfx_trail_node = shadow_bullet_trail_node.instance()
	vfx_trail_node.position = bullet.position
	vfx_trail_node.track(bullet)
	bullet.connect("stop_emitting_particles", vfx_trail_node, "_on_stop_emitting_particles")
	current_viewport.add_child(vfx_trail_node)


func point_number(value:int, pos:Vector2, txtcolor:Color):
	var vfx_node = point_number_node.instance()
	vfx_node.position = pos
	vfx_node.value = value
	vfx_node.modulate = txtcolor
	current_viewport.add_child(vfx_node)


func ripple_vfx(pos:Vector2, dir:int, time:float):
	#control variables (init as 0 in case dir is passed erroneously)
	var starting_scale : float = 0
	var ending_scale : float = 0
	var strenght_max : float = 0.2
	#set values according to directon
	if dir == OUTWARD:
		starting_scale = 0.15
		ending_scale = 1.0
	elif dir == INWARD:
		starting_scale = 1.0
		ending_scale = 0.1
	#set ripple position
	current_viewport_background.material.set_shader_param("node_position", pos)
	#add tweens
	var scale_tween = Tween.new()
	var strenght_tween = Tween.new()
	current_viewport_background.add_child(scale_tween)
	current_viewport_background.add_child(strenght_tween)
	#interpolate tweens with control variables
	scale_tween.interpolate_property(current_viewport_background.material, "shader_param/scale_factor", starting_scale, ending_scale, time + 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	scale_tween.start()
	strenght_tween.interpolate_property(current_viewport_background.material, "shader_param/effect_strenght", 0, strenght_max, 0.33 * time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	strenght_tween.start()
	yield(strenght_tween,"tween_all_completed")
	strenght_tween.interpolate_property(current_viewport_background.material, "shader_param/effect_strenght", strenght_max, 0, 0.5 * time, Tween.TRANS_SINE, Tween.EASE_IN)
	strenght_tween.start()
	#remove tweens
	yield(strenght_tween,"tween_all_completed")
	scale_tween.queue_free()
	strenght_tween.queue_free()


func bloom_vfx(time:float):
	#enable shader
	current_viewport_container.material.set_shader_param("effect_on", true)
	#add tween
	var pulse_tween = Tween.new()
	current_viewport_container.add_child(pulse_tween)
	#interpolate tweens
	pulse_tween.interpolate_property(current_viewport_container.material, "shader_param/intensity", 0, 1, time*0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pulse_tween.start()
	yield(pulse_tween, "tween_all_completed")
	pulse_tween.interpolate_property(current_viewport_container.material, "shader_param/intensity", 1, 0, time*0.7, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	pulse_tween.start()
	yield(pulse_tween, "tween_all_completed")
	#disable shader
	current_viewport_container.material.set_shader_param("effect_on", false)
	#remove tween
	pulse_tween.queue_free()


func boss_end_vfx(pos:Vector2):
	for i in range(30):
		if i == 0:
			var vfx_sprite = creep_explode_node.instance()
			vfx_sprite.position = pos
			vfx_sprite.scale *= 4
			vfx_sprite.z_index = Global.CustomLayers.VFX
			add_child(vfx_sprite)
		else:
			var vfx_sprite = creep_explode_node.instance()
			vfx_sprite.position = pos + Vector2(-20+(40*randf()),-20+(40*randf()))
			vfx_sprite.scale *= 1.5 + 1.5*randf()
			vfx_sprite.z_index = Global.CustomLayers.VFX
			if i%2 == 0:
				vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.0, 1.5, 2.5 ))
			else:
				vfx_sprite.material.set_shader_param("color_modifier", Vector3( 1.0, 2.5, 1.5 ))
			add_child(vfx_sprite)
			yield(get_tree().create_timer(0.1 + 0.1 * randf(), false),"timeout")
