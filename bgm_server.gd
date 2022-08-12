extends Node2D

class_name BGMServer

var music_stopped = true

enum {STAGE_1, BOSS_1}


func _ready():
	$bgm02_start.stream.loop = false
	$bgm03_start.stream.loop = false
	AudioServer.set_bus_effect_enabled(1,0,false)


func _on_bgm02_start_finished():
	if music_stopped == false:
		$bgm02_loop.play()


func _on_bgm03_start_finished():
	if music_stopped == false:
		$bgm03_loop.play()



func change_bgm(play_next_id:int):
	
	if PlayerVars.music:
		
		music_stopped = true
		
		var currently_playing_bgm
		for bgm_stream in get_children():
			if bgm_stream is AudioStreamPlayer:
				if bgm_stream.playing == true:
					currently_playing_bgm = bgm_stream
					
		$volume_tween.interpolate_property(currently_playing_bgm, "volume_db", 0.0, -36.0, 1, Tween.TRANS_LINEAR)
		$volume_tween.start()
		
		yield($volume_tween, "tween_all_completed")
		currently_playing_bgm.stop()
		play_bgm(play_next_id)
		
	else:
		return



func play_bgm(bgm_id:int):
	
	if PlayerVars.music:
	
		match bgm_id:
			STAGE_1:
				$bgm02_start.play()
			BOSS_1:
				$bgm03_start.play()
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		music_stopped = false
	
	else:
		return



func end_fadeout(fadeout_time:float):
	
	music_stopped = true
	
	if PlayerVars.music:
		
		var currently_playing_bgm
		for bgm_stream in get_children():
			if bgm_stream is AudioStreamPlayer:
				if bgm_stream.playing == true:
					currently_playing_bgm = bgm_stream
		
		$volume_tween.interpolate_property(currently_playing_bgm, "volume_db", 0.0, -36.0, fadeout_time, Tween.TRANS_LINEAR)
		$volume_tween.start()
		
		yield($volume_tween, "tween_all_completed")
		currently_playing_bgm.stop()
		
	else:
		return



func lowpass_on():
	AudioServer.set_bus_effect_enabled(1,0,true)

func lowpass_off():
	AudioServer.set_bus_effect_enabled(1,0,false)


