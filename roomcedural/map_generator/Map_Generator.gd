extends Node2D

const ROOM_SIZE : int = 8

enum exit_dir {UP, DOWN, LEFT, RIGHT}

const MAP_SIZE : Vector2 = Vector2(40, 40)
const START_POS : Vector2 = Vector2(20, 20)

var map_data : Array

func _ready():
	randomize()

	for x in range(MAP_SIZE.x):
		map_data.append([])
		for _y in range(MAP_SIZE.y):
			map_data[x].append(null)

	var from_direction = exit_dir.UP
	var room_pos = START_POS

	var created_rooms : int = 0

	$Room_Manager.prepare_room_list()

	while created_rooms < 30:
		#print("Making room in "+str(room_pos))
		var new_room = $Room_Manager.get_room()

		if new_room == null:
			print("Room List Empty!")
			break

		var fits : bool = false
		var room_placement_pos : Vector2

		new_room.exits.shuffle()
		#Check/get new room's entrance
		for entrance in new_room.exits:
			if entrance[1] == from_direction:

				room_placement_pos = room_pos - entrance[0]
				fits = true

				for pos in new_room.positions:
					var map_pos : Vector2 = room_placement_pos + pos
					if map_pos.x < 0 or map_pos.x >= MAP_SIZE.x or \
					   map_pos.y < 0 or map_pos.y >= MAP_SIZE.y or \
					   map_data[map_pos.x][map_pos.y] != null:
						fits = false
						break

				if fits:
					break

		if not fits:
			continue

		created_rooms += 1
		#print("\tmarking rooms in map_data")
		for pos in new_room.positions:
			var map_pos : Vector2 = room_placement_pos + pos
			map_data[map_pos.x][map_pos.y] = new_room
			#print("\t\t"+str(map_pos))

		for tile in new_room.tiles:
			var tile_pos : Vector2 = tile[0] + room_placement_pos*ROOM_SIZE
			$Tile_Map.set_cell(tile_pos.x, tile_pos.y, tile[1])

		for exit in new_room.exits:
			#print("\tgetting exit from "+str(room_placement_pos+exit[0])+" in direction "+str(exit[1]))
			if dir_is_valid(room_placement_pos+exit[0], exit[1]):
				match(exit[1]):

					exit_dir.UP:
						from_direction = exit_dir.DOWN
						room_pos = room_placement_pos + exit[0] + Vector2.UP

					exit_dir.DOWN:
						from_direction = exit_dir.UP
						room_pos = room_placement_pos + exit[0] + Vector2.DOWN

					exit_dir.LEFT:
						from_direction = exit_dir.RIGHT
						room_pos = room_placement_pos + exit[0] + Vector2.LEFT

					exit_dir.RIGHT:
						from_direction = exit_dir.LEFT
						room_pos = room_placement_pos + exit[0] + Vector2.RIGHT

				break

		$Room_Manager.prepare_room_list()

func dir_is_valid(room_pos : Vector2, direction : int) -> bool:
	match(direction):

		exit_dir.UP:
			if (room_pos.y - 1) < 0 or map_data[room_pos.x][room_pos.y-1] != null:
				return false

		exit_dir.DOWN:
			if (room_pos.y + 1) >= MAP_SIZE.y or map_data[room_pos.x][room_pos.y+1] != null:
				return false

		exit_dir.LEFT:
			if (room_pos.x - 1) < 0 or map_data[room_pos.x-1][room_pos.y] != null:
				return false

		exit_dir.RIGHT:
			if (room_pos.x + 1) >= MAP_SIZE.y or map_data[room_pos.x+1][room_pos.y] != null:
				return false

	return true
