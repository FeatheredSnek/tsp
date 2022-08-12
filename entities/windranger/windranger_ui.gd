extends Node2D

onready var indicator_attack = preload("res://ui/ingame/indicator_attack.tscn")
onready var indicator_spell = preload("res://ui/ingame/indicator_spell.tscn")

onready var stylebox_attack = load("res://ui/stylebox_attack.tres")
onready var stylebox_spell = load("res://ui/stylebox_spell.tres")

var spell_values_enabled = false
var health_bar_locked = true


func _ready():
	pass


func construct_ui(phase_list, first_attack_data):
	for p in phase_list:
		if p == "spell":
			var indicator = indicator_spell.instance()
			$phase_list_container.add_child(indicator)
		elif p == "attack":
			var indicator = indicator_attack.instance()
			$phase_list_container.add_child(indicator)
	$health_bar.max_value = float(first_attack_data[0])
	$health_bar.value = float(first_attack_data[0])
	$attack_timer.text = str(first_attack_data[1])

func hide_ui():
	$general_animations.play("hide_ui")

func _on_update_hp(new_hp):
	if not health_bar_locked:
		$health_bar.value = float(new_hp)

func _on_update_time(new_time):
	$attack_timer.text = str(new_time)

func _on_update_bonus(new_bonus_value):
	$bonus_value.text = str(new_bonus_value)


func _on_windranger_attack_start_signal(attack_name, attack_is_spell, attack_health, attack_time, attack_bonus):
	$phase_list_container.get_child(0).queue_free()
	$attack_timer.text = str(attack_time)
	$timer_animations.play("timer_show")
	$health_bar.max_value = float(attack_health)
	$health_bar.value = 0
	$health_bar_animation.interpolate_property($health_bar, "value", 0, $health_bar.max_value, 1, Tween.TRANS_LINEAR)
	$health_bar_animation.start()
	if attack_is_spell:
		$health_bar.set("custom_styles/fg", stylebox_spell)
		$spell_name.text = attack_name
		$bonus_value.text = str(attack_bonus)
		$spell_values_animation.play("show_spell_values")
		spell_values_enabled = true
		$spell_splash/spell_name_container/spell_name_value.text = attack_name.to_upper()
		$spell_splash/spell_name_container/max_bonus_value.text = str(attack_bonus)
		$spell_splash/spell_splash_animations.play("show")
	else:
		$health_bar.set("custom_styles/fg", stylebox_attack)
	yield($health_bar_animation,"tween_all_completed")
	health_bar_locked = false


func _on_windranger_attack_cycle_start():
	$general_animations.play("show_ui")


func _on_windranger_attack_stop_signal(bonus_acheived):
	$timer_animations.play_backwards("timer_show")
	if spell_values_enabled:
		$spell_values_animation.play_backwards("show_spell_values")
	if bonus_acheived is int:
		$spell_end_bonus/value.text = "+" + str(bonus_acheived)
		$spell_end_bonus/spell_bonus_animation.play("show_bonus")
	health_bar_locked = true
	if $health_bar.value > 0:
		$health_bar_animation.interpolate_property($health_bar, "value", $health_bar.value, 0, 0.5)
		$health_bar_animation.start()


func _on_windranger_attack_cycle_stop():
	$general_animations.play("hide_ui")
	pass





func disable_ui():
	visible = false
