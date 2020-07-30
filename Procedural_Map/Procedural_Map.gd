extends Node2D

const ROOM_RES = preload("res://Rooms/Rooms.tscn")
const ROOM_SIZE = 8

func _ready():
	var rooms : Node2D = ROOM_RES.instance()
	var size := Vector2(2,2)
	for x in range(size.x):
		for y in range(size.y):
			copy_room(Vector2(x*ROOM_SIZE, y*ROOM_SIZE), rooms.get_room(0))

func copy_room(pos : Vector2, room : Array) -> void:
	for tile_info in room:
		var tile_pos = tile_info[0] + pos
		$Map.set_cell(tile_pos.x, tile_pos.y, tile_info[1])
