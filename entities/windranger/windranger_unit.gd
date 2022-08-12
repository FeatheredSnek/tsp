extends Node2D

var previous_position
var position_difference = 0
var averaged_velocity = 0

var attacking_animation = false
var frame_counter = 0



func _ready():
	
	self.z_index = Global.CustomLayers.ENEMY_SPRITE
	$wr_seal_inner.z_index = Global.CustomLayers.BOSS_SEAL
	$wr_seal_outer.z_index = Global.CustomLayers.BOSS_SEAL
	
	previous_position = position.x



func _physics_process(_delta):

	if frame_counter % 5 == 0:
		
		position_difference = previous_position - position.x
		$wr_sprite/wr_legs.rotation_degrees = clamp(position_difference, -15, 15) * -1

		previous_position = position.x

	frame_counter += 1
	pass



func move_to(target, travel_time, transition, easing):
	
	if easing < 4:
		$movement_tween.interpolate_property(self, "position", position, 
		target, travel_time, transition, easing)
		$movement_tween.start()
	else:
		$movement_tween.interpolate_property(self, "position", position, 
		target, travel_time, transition)
		$movement_tween.start()
	
	return target



func animation_directed_name():
	
	var angle_to_player = position.angle_to_point(PlayerVars.position)
	
	if cos(angle_to_player) < -0.85:
		return "wr_shot_left"
	elif cos(angle_to_player) > 0.85:
		return "wr_shot_right"
	elif sin(angle_to_player) > 0.5:
		return "wr_shot_up"
	elif sin(angle_to_player) < 0.5:
		return "wr_shot_down"



func animate_attack(looped):

	if not looped:
		$wr_sprite_animations.play(animation_directed_name(), -1, 3)
		$wr_sprite_animations.get_animation($wr_sprite_animations.current_animation).loop = false
		$wr_sprite_animations.queue("wr_idle")
		attacking_animation = false
	else:
		attacking_animation = true
		while attacking_animation == true:
			$wr_sprite_animations.play(animation_directed_name(), -1, 3)
			yield($wr_sprite_animations, "animation_finished")


func animate_single_attack():
	$wr_sprite_animations.play(animation_directed_name(), -1, 3)
	$wr_sprite_animations.get_animation($wr_sprite_animations.current_animation).loop = false


func animate_idle():
	
	attacking_animation = false
	$wr_sprite_animations.play("wr_idle")


