extends Node2D

const ROOM_SIZE : int = 8

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS}

const MAP_SIZE : Vector2 = Vector2(10, 10)
const START_POS : Vector2 = Vector2(5, 5)

var map_data : Array

func _ready():
	randomize()

	for x in range(MAP_SIZE.x):
		map_data.append([])
		for _y in range(MAP_SIZE.y):
			map_data[x].append(null)

	var room_list : Array = []
	var room_pos = START_POS
	var from_direction : int = exit_dir.UP
	var exit_data : Array = [from_direction, room_pos]

	room_list += make_path(exit_data[1], exit_data[0], 3)

#	var room_list_pointer : int = room_list.size() - (randi()%4 + 1)
#
#	while true:
#		if room_list_pointer == 0:
#			print("Room List is Empty in Branch!")
#			exit_data = []
#			break
#
#		var branch_room = room_list[room_list_pointer]
#		exit_data = choose_exit(branch_room, branch_room.map_position)
#
#		if not exit_data.empty():
#			break
#
#		room_list_pointer -= 1
#
#	if not exit_data.empty():
#		room_list += make_path(exit_data[1], exit_data[0], 8, $Tile_Map2)
#
#	#Closing not used exits
#	for room in room_list:
#		close_exits(room)

	var map : String = ""

	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			if map_data[y][x] == null:
				map += "[ ]"
			else:
				map += "[X]"
		map += "\n"

	print(map)

	self.add_child(map_data[cur_pos.x][cur_pos.y].node)
	map_data[cur_pos.x][cur_pos.y].node.connect("player_exited", self, "_room_exited")
	$Player.position = Vector2(128, 128)

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

func choose_exit(new_room : Dictionary, room_placement_pos : Vector2) -> Array:
	var exit_data : Array = []

	for exit in new_room.node.exits:
		#print("\tgetting exit from "+str(room_placement_pos+exit.position)+" in direction "+str(exit[1]))
		if dir_is_valid(room_placement_pos + exit.position, exit.direction):
			match(exit.direction):

				exit_dir.UP:
					exit_data.append(exit_dir.DOWN)
					exit_data.append(room_placement_pos + exit.position + Vector2.UP)

				exit_dir.DOWN:
					exit_data.append(exit_dir.UP)
					exit_data.append(room_placement_pos + exit.position + Vector2.DOWN)

				exit_dir.LEFT:
					exit_data.append(exit_dir.RIGHT)
					exit_data.append(room_placement_pos + exit.position + Vector2.LEFT)

				exit_dir.RIGHT:
					exit_data.append(exit_dir.LEFT)
					exit_data.append(room_placement_pos + exit.position + Vector2.RIGHT)

			new_room.exits.append({"id": exit.id, "to": exit_data[1]})
			new_room.node.exits.erase(exit)
			break

	return exit_data

func place_room(room_data : Dictionary) -> void:
	var new_room = room_data.node
	var room_placement_pos = room_data.map_position
	#print("\tmarking rooms in map_data")
	for pos in new_room.room_positions:
		var map_pos : Vector2 = room_placement_pos + pos
		map_data[map_pos.x][map_pos.y] = room_data
		#print("\t\t"+str(map_pos))

func make_path(start_pos : Vector2, start_dir : int, path_limit : int = 4) -> Array:

	var rooms_list : Array = []

	var from_pos : Vector2 = start_pos
	var room_pos : Vector2 = start_pos
	var from_direction : int = start_dir

	#Create Normal Rooms
	var created_rooms : int = 0
	var exit_data : Array
	$Room_Manager.prepare_room_list(room_types.NORMAL, from_direction)

	while created_rooms < path_limit:
		#print("Attempting room in "+str(room_pos))
		var new_room : Dictionary = {}
		new_room["node"] = $Room_Manager.get_room()

		if new_room.node == null:
			print("\tRoom List Empty!")
			break

		var fits : bool = false
		var room_placement_pos : Vector2

		new_room.node.exits.shuffle()
		#Check/get new room's entrance
		for entrance in new_room.node.exits:
			if entrance.direction == from_direction:

				room_placement_pos = room_pos - entrance.position
				fits = true

				for pos in new_room.node.room_positions:
					var map_pos : Vector2 = room_placement_pos + pos
					if map_pos.x < 0 or map_pos.x >= MAP_SIZE.x or \
					   map_pos.y < 0 or map_pos.y >= MAP_SIZE.y or \
					   map_data[map_pos.x][map_pos.y] != null:
						#print("\tDoesn't fit because of "+str(map_pos))
						fits = false
						break

				if fits:
					new_room["exits"] = [{"id": entrance.id, "to": from_pos}]
					new_room.node.exits.erase(entrance)
					break

		if not fits:
			continue

		exit_data = self.choose_exit(new_room, room_placement_pos)

		if exit_data.empty():
			#print("\tNo Available Exits!")
			continue

		created_rooms += 1
		new_room["map_position"] = room_placement_pos
		rooms_list.append(new_room)
		self.place_room(new_room)

		from_direction = exit_data[0]
		from_pos = room_pos
		room_pos = exit_data[1]

		$Room_Manager.prepare_room_list(room_types.NORMAL, from_direction)

	#Adding Power Room
#	$Room_Manager.prepare_room_list(room_types.POWER)
#	var power_room = $Room_Manager.get_room()
#	exit_data = choose_exit(power_room, room_pos)
#	power_room["map_position"] = room_pos
#	place_room(power_room)

	return rooms_list

var cur_pos : Vector2 = START_POS

func change_room(next_room : Vector2):
	var room = map_data[cur_pos.x][cur_pos.y].node
	room.call_deferred("disconnect", "player_exited", self, "_room_exited")

	self.call_deferred("remove_child", room)

	cur_pos = next_room
	print(cur_pos)
	room = map_data[cur_pos.x][cur_pos.y].node

	self.call_deferred("add_child", room)
	room.call_deferred("connect", "player_exited", self, "_room_exited")

	$Player.position = Vector2(128, 128)

func _room_exited(exit_id : int):
	var cur_room = map_data[cur_pos.x][cur_pos.y]

	for exit in cur_room.exits:
		if exit.id == exit_id:
			if map_data[exit.to.x][exit.to.y] != null:
				change_room(exit.to)
			else:
				print("no exit")
			break
