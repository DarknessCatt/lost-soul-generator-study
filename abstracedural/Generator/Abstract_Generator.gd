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

	var room_pos = START_POS
	var start_data : Dictionary

	#Create Start Room
	$Room_Manager.prepare_room_list(room_types.START)

	var start_room : Dictionary = {}
	start_room["node"] = $Room_Manager.get_room()
	start_room.node.exits.shuffle()
	start_room["map_position"] = room_pos
	start_data = choose_exit(start_room, room_pos)
	start_room["exits"] = [{"id": start_data.id, "to": start_data.to}]
	start_data["pos"] = room_pos
	start_data["exit"] = start_room["exits"][0]
	place_room(start_room)

	var room_list : Array = [start_room]

	room_list += make_path(start_data, 5)

	room_list += make_branch(room_list)
	room_list += make_branch(room_list, 6)
	room_list += make_branch(room_list, 7, 6)

	var map : String = ""

	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			if x == START_POS.x and y == START_POS.y:
				map += "[S]"

			elif map_data[y][x] == null:
				map += "[ ]"

			else:
				map += "[X]"

		map += "\n"

	print(map)

	for room in room_list: room.node.open_exits(room.exits)

	self.add_child(map_data[cur_pos.x][cur_pos.y].node)
	map_data[cur_pos.x][cur_pos.y].node.connect("player_exited", self, "_room_exited")
	$Player.position = Vector2(128, 128)

func make_branch(room_list : Array, initial_backtrack : int = 4, size : int = 3):
	var room_list_pointer : int = room_list.size() - (randi()%initial_backtrack+1)
	var branch_data = {}

	while true:
		if room_list_pointer == 0:
			print("Room List is Empty in Branch!")
			branch_data = {}
			break

		var branch_room = room_list[room_list_pointer]
		branch_data = choose_exit(branch_room, branch_room.map_position)

		if not branch_data.empty():
			branch_room["exits"].append({"id": branch_data.id, "to": branch_data.to})
			branch_data["pos"] = branch_room.map_position
			branch_data["exit"] = branch_room["exits"].back()
			break

		room_list_pointer -= 1

	if not branch_data.empty():
		return make_path(branch_data, size)

	else:
		return []

# start_data:
#	pos = position of the original room
#	id = exit.id from original room
#	to = position of the new room
#	dir = direction it comes from
#	entrance = pointer to previous exit
func make_path(start_data : Dictionary, path_limit : int = 4) -> Array:

	var rooms_list : Array = []

	var previous_room : Dictionary = {"pos": start_data.pos, "exit_id": start_data.id, "exit_dir": start_data.dir, "exit_dic": start_data.exit}
	var room_pos : Vector2 = start_data.to

	#Create Normal Rooms
	var created_rooms : int = 0
	var exit_data : Dictionary = {}

	$Room_Manager.prepare_room_list(room_types.NORMAL, previous_room.exit_dir)

	while created_rooms < path_limit:
		#print("Attempting room in "+str(room_pos))
		var new_room : Dictionary = {}
		new_room["node"] = $Room_Manager.get_room()

		if new_room.node == null:
			print("\tRoom List Empty!")
			break

		var fits : bool = false
		var return_exit_info : Dictionary
		var room_placement_pos : Vector2

		new_room.node.exits.shuffle()
		#Check/get new room's entrance
		for entrance in new_room.node.exits:
			if entrance.direction == previous_room.exit_dir:

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
					return_exit_info = {"id": entrance.id, "to": previous_room.pos, "entrance": previous_room.exit_id}
					break

		if not fits:
			continue

		exit_data = self.choose_exit(new_room, room_placement_pos)

		if exit_data.empty():
			#print("\tNo Available Exits!")
			continue

		var next_exit : Dictionary = {"id": exit_data.id, "to": exit_data.to}

		new_room["exits"] = [next_exit]
		new_room["exits"].append(return_exit_info)
		previous_room.exit_dic["entrance"] = return_exit_info.id

		created_rooms += 1
		new_room["map_position"] = room_placement_pos
		rooms_list.append(new_room)
		self.place_room(new_room)

		previous_room.exit_id = exit_data.id
		previous_room.exit_dir = exit_data.dir
		previous_room.pos = room_pos
		previous_room.exit_dic = next_exit

		room_pos = exit_data.to

		$Room_Manager.prepare_room_list(room_types.NORMAL, previous_room.exit_dir)

	#Adding Power Room
	$Room_Manager.prepare_room_list(room_types.POWER)
	var power_room : Dictionary = {}
	power_room["node"] = $Room_Manager.get_room()

	for entrance in power_room.node.exits:
		if entrance.direction == previous_room.exit_dir:

			var room_placement_pos = room_pos - entrance.position
			var fits = true

			for pos in power_room.node.room_positions:
				var map_pos : Vector2 = room_placement_pos + pos
				if map_pos.x < 0 or map_pos.x >= MAP_SIZE.x or \
				   map_pos.y < 0 or map_pos.y >= MAP_SIZE.y or \
				   map_data[map_pos.x][map_pos.y] != null:
					#print("\tDoesn't fit because of "+str(map_pos))
					fits = false
					break

			if fits:
				previous_room.exit_dic["entrance"] = entrance.id
				power_room["map_position"] = room_placement_pos
				power_room["exits"] = [{"id": entrance.id, "to": previous_room.pos, "entrance": previous_room.exit_id}]
				break

	place_room(power_room)
	rooms_list.append(power_room)
	return rooms_list

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

func choose_exit(new_room : Dictionary, room_placement_pos : Vector2) -> Dictionary:
	var exit_data : Dictionary = {}

	for exit in new_room.node.exits:
		#print("\tgetting exit from "+str(room_placement_pos+exit.position)+" in direction "+str(exit[1]))
		if dir_is_valid(room_placement_pos + exit.position, exit.direction):
			match(exit.direction):

				exit_dir.UP:
					exit_data["dir"] = exit_dir.DOWN
					exit_data["to"] = (room_placement_pos + exit.position + Vector2.UP)

				exit_dir.DOWN:
					exit_data["dir"] = exit_dir.UP
					exit_data["to"] = (room_placement_pos + exit.position + Vector2.DOWN)

				exit_dir.LEFT:
					exit_data["dir"] = exit_dir.RIGHT
					exit_data["to"] = (room_placement_pos + exit.position + Vector2.LEFT)

				exit_dir.RIGHT:
					exit_data["dir"] = exit_dir.LEFT
					exit_data["to"] = (room_placement_pos + exit.position + Vector2.RIGHT)

			exit_data["id"] = exit.id
			#new_room.exits.append({"id": exit.id, "to": exit_data[1]})
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

var changing : bool = false
var cur_pos : Vector2 = START_POS

func change_room(next_room : Vector2, exit_pos : Vector2):
	changing = true
	$can_exit.start()
	var room = map_data[cur_pos.x][cur_pos.y].node
	room.call_deferred("disconnect", "player_exited", self, "_room_exited")

	self.call_deferred("remove_child", room)

	cur_pos = next_room
	#print(exit_pos)
	room = map_data[cur_pos.x][cur_pos.y].node

	$Player.position = Vector2(128*(1+int(exit_pos.x)*2), 128*(1+int(exit_pos.y)*2))

	self.call_deferred("add_child", room)
	room.call_deferred("connect", "player_exited", self, "_room_exited")

func _room_exited(exit_id : int):
	if not changing:
		var cur_room = map_data[cur_pos.x][cur_pos.y]

		for exit in cur_room.exits:
			if exit.id == exit_id:
				if map_data[exit.to.x][exit.to.y] != null:
					var pos = find_exit_id(exit.entrance, map_data[exit.to.x][exit.to.y].node.exits).position
					change_room(exit.to, pos)
				else:
					print("no exit")
				break

func find_exit_id(id : int, exits : Array):
	var exit_data

	for exit in exits:
		if exit.id == id:
			exit_data = exit
			break

	return exit_data

func _on_can_exit_timeout():
	changing = false
