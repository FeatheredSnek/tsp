extends Sprite

func _ready():
	$gauge_bar.max_value = PlayerVars.shadow_gauge_treshold
	$gauge_bar.value = 0

func _on_player_inst_update_shadow():
	var current = $gauge_bar.value
	$gauge_bar.value = PlayerVars.shadow_gauge_value
	if $gauge_bar.value == $gauge_bar.max_value:
		$gauge_glow_ani.play("pulse")
	elif $gauge_bar.value == 0:
		$gauge_glow_ani.play("explode")
	elif $gauge_bar.value < current and $gauge_bar.value > 0:
		$gauge_glow_ani.play("hide")

func _on_gauge_hide_area_area_entered(area):
	$gauge_hider.play("hide")

func _on_gauge_hide_area_area_exited(area):
	$gauge_hider.play_backwards("hide")
