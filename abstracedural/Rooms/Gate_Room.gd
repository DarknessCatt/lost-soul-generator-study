extends Base_Room

func _on_Left_Exit_entered(_body):
	emit_signal("player_exited", 0)

func _on_Right_Exit_entered(_body):
	emit_signal("player_exited", 1)
