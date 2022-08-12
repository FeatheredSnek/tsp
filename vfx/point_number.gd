extends Node2D

var mod = 2.0
var value = 1234567890

func _ready():
	$point_number_value.text = "+" + str(value)

func _physics_process(delta):
	position.y -= 0.5
	mod -= 0.03
	$point_number_value.modulate = Color(1.0, 1.0, 1.0, mod)
	if mod == 0:
		queue_free()

