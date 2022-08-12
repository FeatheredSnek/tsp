extends Node2D


var tracking = false
var tracked_boss_unit


func _ready():
	pass


func _physics_process(delta):
	if tracking:
		$boss_indicator.position.x = tracked_boss_unit.position.x


func _on_game_viewport_boss_entered(unit):
	$boss_indicator.visible = true
	tracking = true
	tracked_boss_unit = unit
