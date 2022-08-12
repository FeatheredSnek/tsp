extends Spatial

func _ready():
	pass

	
func _on_game_viewport_game_over():
	var camera_stop_tween = Tween.new()
	add_child(camera_stop_tween)
	camera_stop_tween.interpolate_property($camera_animation, "playback_speed", $camera_animation.playback_speed, 0, 2, Tween.TRANS_EXPO, Tween.EASE_OUT) 
	camera_stop_tween.start()
	yield(camera_stop_tween,"tween_all_completed")
	$camera_animation.stop(false)


func _on_dialogue_finished():
	$camera_animation.play("end_loop_transition")
	$camera_animation.queue("end_loop")
