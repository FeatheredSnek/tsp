extends Sprite

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
