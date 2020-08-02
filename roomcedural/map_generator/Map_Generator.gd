extends Node2D

const ROOM_SIZE : int = 8

enum exir_dir {UP, DOWN, LEFT, RIGHT}
const dir_to_vec : Dictionary = {	exir_dir.UP : Vector2.UP, exir_dir.DOWN : Vector2.DOWN,
									exir_dir.LEFT : Vector2.LEFT, exir_dir.RIGHT : Vector2.RIGHT }

const MAP_SIZE : Vector2 = Vector2(10, 10)
const START_POS : Vector2 = Vector2(5, 5)

var map_data : Array
var move_directions : Array = [exir_dir.UP, exir_dir.DOWN, exir_dir.LEFT, exir_dir.RIGHT]

func _ready():
	randomize()

	for x in range(MAP_SIZE.x):
		map_data.append([])
		for _y in range(MAP_SIZE.y):
			map_data[x].append(null)

	var from_direction = exir_dir.UP
	var room_pos = START_POS

	var created_rooms : int = 0

	while created_rooms < 3:
		var new_room : Dictionary = $Room_Manager.get_room()

		#Check if the new_room fits
		var fits : bool = true

		for pos in new_room.positions:
			var map_pos : Vector2 = room_pos + pos
			if map_data[map_pos.x][map_pos.y] != null:
				fits = false
				break

		if fits:
			created_rooms += 1
			for pos in new_room.positions:
				var map_pos : Vector2 = room_pos + pos
				map_data[map_pos.x][map_pos.y] = new_room

			for tile in new_room.tiles:
				var tile_pos : Vector2 = tile[0] + room_pos*ROOM_SIZE
				$Tile_Map.set_cell(tile_pos.x, tile_pos.y, tile[1])

			new_room.exits.shuffle()

			for exit in new_room.exits:
				if dir_is_valid(room_pos+exit[0], exit[1]):
					from_direction = exit[1]
					room_pos = room_pos + exit[0] + dir_to_vec[exit[1]]
					break

func dir_is_valid(room_pos : Vector2, direction : int) -> bool:
	match(direction):

		exir_dir.UP:
			if (room_pos.y - 1) < 0 or map_data[room_pos.x][room_pos.y-1] != null:
				return false

		exir_dir.DOWN:
			if (room_pos.y + 1) > MAP_SIZE.y or map_data[room_pos.x][room_pos.y+1] != null:
				return false

		exir_dir.RIGHT:
			if (room_pos.x - 1) < 0 or map_data[room_pos.x-1][room_pos.y] != null:
				return false

		exir_dir.RIGHT:
			if (room_pos.x + 1) > MAP_SIZE.y or map_data[room_pos.x+1][room_pos.y] != null:
				return false

	return true
