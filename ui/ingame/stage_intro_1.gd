extends Node2D

func _ready():
	$stage_name/stage_highscore.text = "BEST SCORE: " + str(PlayerVars.stage_1_highscore)
	self.z_index = Global.CustomLayers.UI_INGAME
