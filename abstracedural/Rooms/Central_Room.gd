extends Base_Room

func _on_Up_Exit_entered(_body):
	emit_signal("player_exited", 0)

func _on_Down_Exit_entered(_body):
	emit_signal("player_exited", 1)

func _on_Left_Exit_entered(_body):
	emit_signal("player_exited", 2)

func _on_Right_Exit_entered(_body):
	emit_signal("player_exited", 3)

func open_exits(exits : Array):

	$Exit_Blocks.show()

	for exit in exits:
		match(exit.id):

			0: $Exit_Blocks.remove_child($Exit_Blocks/Up)
			1: $Exit_Blocks.remove_child($Exit_Blocks/Down)
			2: $Exit_Blocks.remove_child($Exit_Blocks/Left)
			3: $Exit_Blocks.remove_child($Exit_Blocks/Right)
