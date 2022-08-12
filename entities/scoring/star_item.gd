extends Item

func _ready():
	self.item_type = 3
	self.acceleration = Vector2.ZERO
	pass


func _physics_process(_delta):
	framecount += 1
	if framecount == 60:
		self.is_homing = true


func _on_drop_timer_timeout():
	self.is_homing = true
