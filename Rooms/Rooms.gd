extends Node2D


func get_room(from : int, to : int) -> Array:
	var data := []
	var room : TileMap = self.get_child(from).get_child(to)

	for v in room.get_used_cells():
		data.append([v, room.get_cellv(v)])

	return data
