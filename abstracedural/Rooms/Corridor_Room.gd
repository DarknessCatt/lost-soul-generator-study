extends Base_Room

func _on_Left_Exit_entered(_body):
	emit_signal("player_exited", 0)

func _on_First_Down_Exit_body_entered(_body):
	emit_signal("player_exited", 1)

func _on_Second_Down_Exit_body_entered(_body):
	emit_signal("player_exited", 2)

func _on_Right_Exit_entered(_body):
	emit_signal("player_exited", 3)

func open_exits(exits : Array):

	var left : bool = false
	var right : bool = false

	for exit_data in exits:
		match(exit_data.exit.id):

			0:
				$Left.remove_child($"Left/0")
				left = true
			1:
				$Left.remove_child($"Left/1")
				left = true
			2:
				$Right.remove_child($"Right/2")
				right = true
			3:
				$Right.remove_child($"Right/3")
				right = true

	if not left: self.remove_child($Left)
	if not right: self.remove_child($Right)
	if left and right: self.remove_child($Division)
