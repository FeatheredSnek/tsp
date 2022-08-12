extends Node2D

signal shaders_loaded
signal effects_loaded

var bullet_shaders = [
	load("res://vfx/shaders/shader_default.tres"),
	load("res://vfx/shaders/shader_gold.tres"),
	load("res://vfx/shaders/shader_green.tres"),
	load("res://vfx/shaders/shader_purple.tres"),
	load("res://vfx/shaders/shader_red.tres")
]

var particle_effects = [
	load("res://vfx/creep_explode.tscn"),
	load("res://vfx/creep_explode_ranged.tscn"),
	
	load("res://vfx/ui_explode_heart.tscn"),
	load("res://vfx/ui_explode_bomb.tscn"),
	
	load("res://vfx/wr_gather_leaves.tscn"),
	load("res://vfx/wr_gather_particles.tscn"),
	load("res://vfx/sc_gather_particles.tscn"),
	
	load("res://vfx/shadow_hit_explode.tscn"),
	load("res://vfx/shadow_bullet_trail.tscn"),

	load("res://vfx/bomb_round.tscn"),
	load("res://vfx/wr_powershot_particles.tscn")
]

func _ready():
	pass

func cycle_shaders():
	for shader in bullet_shaders:
		$shaders_sprite.material = shader
		yield(get_tree(),"idle_frame")
	emit_signal("shaders_loaded")

func cycle_effects():
	for effect in particle_effects:
		add_child(effect.instance())
		yield(get_tree(),"idle_frame")
	emit_signal("effects_loaded")
		
