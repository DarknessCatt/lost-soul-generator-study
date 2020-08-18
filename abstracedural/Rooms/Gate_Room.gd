extends Base_Room

const left_exits = [0, 1, 2]
const right_exits = [3, 4, 5]

func _on_Left_Exit_entered(_body):
	emit_signal("player_exited", 0)

func _on_Up_Left_Exit_body_entered(_body):
	emit_signal("player_exited", 1)

func _on_Down_Left_Exit_body_entered(_body):
	emit_signal("player_exited", 2)

func _on_Right_Exit_entered(_body):
	emit_signal("player_exited", 3)

func _on_Up_Right_Exit_body_entered(_body):
	emit_signal("player_exited", 4)

func _on_Down_Right_Exit_body_entered(_body):
	emit_signal("player_exited", 5)

func erase_exit(exit):
	var exits_to_erase_id : Array = right_exits
	var exits_to_erase_ar : Array = []

	if exit.id in left_exits: exits_to_erase_id = left_exits

	for ex in self.exits:
		if ex.id in exits_to_erase_id:
			exits_to_erase_ar.append(ex)

	for ex in exits_to_erase_ar:
		self.exits.erase(ex)

func open_exits(exits : Array):
	$Exit_Blocks.show()
	for exit in exits: $Exit_Blocks.remove_child($Exit_Blocks.get_node(str(exit.exit.id)))
