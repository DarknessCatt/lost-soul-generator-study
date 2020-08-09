extends Base_Room

func _on_Exit_entered(_body):
	emit_signal("player_exited", 0)
