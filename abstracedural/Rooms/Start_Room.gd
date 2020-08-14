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
	for exit_data in exits: $Exit_Blocks.remove_child($Exit_Blocks.get_node(str(exit_data.exit.id)))
