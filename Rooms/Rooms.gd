extends Node2D


func get_room(_type : int) -> Array:
	var data := []
	var room : TileMap = self.get_child(0)
	for v in room.get_used_cells():
		data.append([v, room.get_cellv(v)])

	return data
