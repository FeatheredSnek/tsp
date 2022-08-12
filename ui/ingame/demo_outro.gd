extends Node2D


func _ready():
	$stage_name/stage_score_value.text = str(PlayerVars.score)
	self.z_index = Global.CustomLayers.UI_INGAME
