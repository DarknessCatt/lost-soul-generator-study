extends Base_Room

func _on_Up_Exit_entered(_body):
	emit_signal("player_exited", 0)

func _on_Down_Exit_entered(_body):
	emit_signal("player_exited", 1)
