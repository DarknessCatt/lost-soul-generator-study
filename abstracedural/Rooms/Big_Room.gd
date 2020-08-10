extends Base_Room

func _on_First_Up_body_entered(_body):
	emit_signal("player_exited", 0)

func _on_Second_Up_body_entered(_body):
	emit_signal("player_exited", 1)

func _on_First_Down_body_entered(_body):
	emit_signal("player_exited", 2)

func _on_Second_Down_body_entered(_body):
	emit_signal("player_exited", 3)

func _on_Right_body_entered(_body):
	emit_signal("player_exited", 4)
