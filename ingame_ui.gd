extends Node2D

var ui_explode_heart_node = preload("res://vfx/ui_explode_heart.tscn")
var ui_explode_bomb_node = preload("res://vfx/ui_explode_bomb.tscn")

onready var score_value = $ui_score_value
onready var shadow_gauge_value = $ui_shadow_gauge_value
onready var v_mult_value = $ui_v_mult_value
onready var s_mult_value = $ui_s_mult_value
onready var graze_value = $ui_graze_value


func _ready():
	
	score_value.text = str(PlayerVars.score)
	shadow_gauge_value.text = str(PlayerVars.shadow_gauge_value)
	v_mult_value.text = str(PlayerVars.v_mult)
	s_mult_value.text = str(PlayerVars.s_mult)
	graze_value.text = str(PlayerVars.graze)
	
	for h in $ui_hp_hearts.get_children():
		h.visible = false
	for i in range(PlayerVars.hp):
		$ui_hp_hearts.get_children()[i].visible = true
	
	for b in $ui_bombs.get_children():
		b.visible = false
	for i in range(PlayerVars.bombs):
		$ui_bombs.get_children()[i].visible = true



func _process(delta):
	score_value.text = str(PlayerVars.score)
	shadow_gauge_value.text = str(PlayerVars.shadow_gauge_value)
	v_mult_value.text = str(PlayerVars.v_mult)
	s_mult_value.text = str(PlayerVars.s_mult)
	graze_value.text = str(PlayerVars.graze)


func _on_player_inst_update_status():
#	update_hp_hearts(PlayerVars.hp)
#	update_bombs(PlayerVars.bombs)
	pass


func update_hp_hearts(new_value:int):
	var hearts = $ui_hp_hearts.get_children()
	var last_heart_position = hearts[new_value].get_global_transform().origin - position + Vector2(-18,12)
	for h in hearts:
		h.visible = false
	if new_value > 0:
		for i in range(new_value):
			hearts[i].visible = true
	var explode_vfx = ui_explode_heart_node.instance()
	explode_vfx.position = last_heart_position
	explode_vfx.emitting = true
	add_child(explode_vfx)
	yield(get_tree().create_timer(1.1,false),"timeout")
	explode_vfx.queue_free()


func update_bombs(new_value:int):
	var bombs = $ui_bombs.get_children()
	var last_bomb_position = bombs[new_value].get_global_transform().origin - position + Vector2(-18,12)
	for b in bombs:
		b.visible = false
	if new_value > 0:
		for i in range(new_value):
			bombs[i].visible = true
	var explode_vfx = ui_explode_bomb_node.instance()
	explode_vfx.position = last_bomb_position
	explode_vfx.emitting = true
	add_child(explode_vfx)
	yield(get_tree().create_timer(1.1,false),"timeout")
	explode_vfx.queue_free()


func _on_player_inst_update_hearts():
	update_hp_hearts(PlayerVars.hp)


func _on_player_inst_update_bombs():
	update_bombs(PlayerVars.bombs)
