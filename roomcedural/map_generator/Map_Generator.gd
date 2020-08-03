extends Node2D

const ROOM_SIZE : int = 8

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS}

const MAP_SIZE : Vector2 = Vector2(40, 40)
const START_POS : Vector2 = Vector2(20, 20)

var map_data : Array

func _ready():
	randomize()

	for x in range(MAP_SIZE.x):
		map_data.append([])
		for _y in range(MAP_SIZE.y):
			map_data[x].append(null)

	var room_pos = START_POS
	var from_direction : int
	var exit_data : Array

	#Create Start Room
	$Room_Manager.prepare_room_list(room_types.START)

	var start_room = $Room_Manager.get_room()
	place_room(start_room, room_pos, $Tile_Map)
	exit_data = choose_exit(start_room, room_pos)

	from_direction = exit_data[0]
	room_pos = exit_data[1]

	#Create Normal Rooms
	var created_rooms : int = 0
	$Room_Manager.prepare_room_list(room_types.NORMAL, from_direction)

	while created_rooms < 50:
		#print("Attempting room in "+str(room_pos))
		var new_room = $Room_Manager.get_room()

		if new_room == null:
			print("\tRoom List Empty!")
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
						#print("\tDoesn't fit because of "+str(map_pos))
						fits = false
						break

				if fits:
					break

		if not fits:
			continue

		exit_data = self.choose_exit(new_room, room_placement_pos)

		if exit_data.empty():
			#print("\tNo Available Exits!")
			continue

		created_rooms += 1
		self.place_room(new_room, room_placement_pos, $Tile_Map)

		from_direction = exit_data[0]
		room_pos = exit_data[1]

		$Room_Manager.prepare_room_list(room_types.NORMAL, from_direction)

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

func place_room(new_room : Dictionary, room_placement_pos : Vector2, tilemap : TileMap) -> void:
	#print("\tmarking rooms in map_data")
	for pos in new_room.positions:
		var map_pos : Vector2 = room_placement_pos + pos
		map_data[map_pos.x][map_pos.y] = new_room
		#print("\t\t"+str(map_pos))

	for tile in new_room.tiles:
		var tile_pos : Vector2 = tile[0] + room_placement_pos*ROOM_SIZE
		tilemap.set_cell(tile_pos.x, tile_pos.y, tile[1])

func choose_exit(new_room : Dictionary, room_placement_pos := Vector2.ZERO) -> Array:
	var exit_data : Array = []

	for exit in new_room.exits:
		#print("\tgetting exit from "+str(room_placement_pos+exit[0])+" in direction "+str(exit[1]))
		if dir_is_valid(room_placement_pos+exit[0], exit[1]):
			match(exit[1]):

				exit_dir.UP:
					exit_data.append(exit_dir.DOWN)
					exit_data.append(room_placement_pos + exit[0] + Vector2.UP)

				exit_dir.DOWN:
					exit_data.append(exit_dir.UP)
					exit_data.append(room_placement_pos + exit[0] + Vector2.DOWN)

				exit_dir.LEFT:
					exit_data.append(exit_dir.RIGHT)
					exit_data.append(room_placement_pos + exit[0] + Vector2.LEFT)

				exit_dir.RIGHT:
					exit_data.append(exit_dir.LEFT)
					exit_data.append(room_placement_pos + exit[0] + Vector2.RIGHT)

			break

	return exit_data
