extends KinematicBody2D

func _physics_process(delta):
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		dir.y = -1

	elif Input.is_action_pressed("ui_down"):
		dir.y = 1

	if Input.is_action_pressed("ui_left"):
		dir.x = -1

	elif Input.is_action_pressed("ui_right"):
		dir.x = 1

	# warning-ignore:return_value_discarded
	self.move_and_slide(dir*80000*delta)

#	$Label.set_text("[ "+str(int(self.position.x)/(8*32))+", "+str(int(self.position.y)/(8*32))+"]")
