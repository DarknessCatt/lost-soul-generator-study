extends Node2D

const ROOM_SIZE : int = 8

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS, GATE}

const MAP_SIZE : Vector2 = Vector2(20, 20)
const START_POS : Vector2 = Vector2(10, 10)

var map_data : Array

func _ready():
	randomize()

	for x in range(MAP_SIZE.x):
		map_data.append([])
		for _y in range(MAP_SIZE.y):
			map_data[x].append(null)

	var room_pos = START_POS

	#Create Start Room
	var start_room : Dictionary = make_special_room(room_pos, room_types.START)
	start_room.room["rank"] = 0

	var room_list : Array = [start_room.room]

	room_list += make_path(start_room.exit, 0, 5)

	room_list += make_branch(room_list, 0, 6, 3, room_types.BONUS)
	room_list += make_branch(room_list, 1)
	room_list += make_branch(room_list, 1, 7, 6, room_types.BONUS)

	make_cycles(room_list)

	var map : String = ""

	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			if x == START_POS.x and y == START_POS.y:
				map += "[S]"

			elif map_data[y][x] == null:
				map += "[ ]"

			else:
				map += "["+str(map_data[y][x].rank)+"]"

		map += "\n"

	print(map)

	for room in room_list: room.node.open_exits(room.exits)

	self.add_child(map_data[cur_pos.x][cur_pos.y].node)
	map_data[cur_pos.x][cur_pos.y].node.connect("player_exited", self, "_room_exited")
	$Player.position = Vector2(128, 128)

func make_cycles(room_list : Array) -> void:

	for room in room_list:
		for exit in room.node.exits:
			var leads_to : Vector2 = room.map_position + exit.position
			var entrance_dir : int

			match(exit.direction):

				exit_dir.UP:
					leads_to += Vector2.UP
					entrance_dir = exit_dir.DOWN

				exit_dir.DOWN:
					leads_to += Vector2.DOWN
					entrance_dir = exit_dir.UP

				exit_dir.RIGHT:
					leads_to += Vector2.RIGHT
					entrance_dir = exit_dir.LEFT

				exit_dir.LEFT:
					leads_to += Vector2.LEFT
					entrance_dir = exit_dir.RIGHT

			if 	leads_to.x < 0 or leads_to.x >= MAP_SIZE.x or \
				leads_to.y < 0 or leads_to.y >= MAP_SIZE.y or \
				map_data[leads_to.x][leads_to.y] == null:
					continue

			var other_room = map_data[leads_to.x][leads_to.y]

			for entrance in other_room.node.exits:
				if 	entrance.direction == entrance_dir and \
					leads_to.x == (other_room.map_position.x + entrance.position.x) and \
					leads_to.y == (other_room.map_position.y + entrance.position.y):

						if  (room.rank == other_room.rank) and \
							(room.node.room_type == room_types.NORMAL or \
							other_room.node.room_type == room_types.NORMAL) and \
							rand_range(0, 1) < 0.5:
							room.exits.append({"exit": exit, "to": leads_to, "entrance": entrance})
							other_room.exits.append({"exit": entrance, "to": (room.map_position + exit.position), "entrance": exit})

						room.node.exits.erase(exit)
						other_room.node.exits.erase(entrance)
						break


func make_branch(room_list : Array, branch_rank : int = 0, initial_backtrack : int = 4, size : int = 3, final_room_type : int = room_types.POWER):
	var room_list_pointer : int = room_list.size() - (randi()%initial_backtrack+2)
	var branch_data = {}

	while true:
		if room_list_pointer == 0:
			print("Room List is Empty in Branch!")
			branch_data = {}
			break

		var branch_room = room_list[room_list_pointer]
		print("Branch in "+str(room_list_pointer))
		branch_data = choose_exit(branch_room, branch_room.map_position)

		if not branch_data.empty():

			var exit = {"exit": branch_data.exit, "to": branch_data.to}

			branch_data["pos"] = branch_room.map_position
			branch_data["exit"] = exit

			if branch_room.rank >= branch_rank:
				branch_rank = branch_room.rank
				branch_room["exits"].append(exit)
				break

			else:
				var gate_room : Dictionary = make_special_room(branch_data.to, room_types.GATE, {"pos": branch_data.pos, "exit_data":branch_data.exit, "exit_dir":branch_data.dir})

				if not gate_room.empty():
					branch_room["exits"].append(exit)
					gate_room.room["rank"] = branch_rank
					return [gate_room.room] + make_path(gate_room.exit, branch_rank, size, final_room_type)

		room_list_pointer -= 1

	if not branch_data.empty():
		return make_path(branch_data, branch_rank, size, final_room_type)

	else:
		return []

# start_data:
#	pos = position of the original room
#	exit = exit from original room
#	to = position of the new room
#	dir = direction it comes from
func make_path(start_data : Dictionary, path_rank : int = 0, path_limit : int = 4, final_room_type : int = room_types.POWER) -> Array:

	var rooms_list : Array = []

	var previous_room : Dictionary = {"pos": start_data.pos, "exit_data": start_data.exit, "exit_dir": start_data.dir}
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
					return_exit_info = {"exit": entrance, "to": previous_room.pos, "entrance": previous_room.exit_data.exit}
					new_room.node.exits.erase(entrance)
					break

		if not fits:
			continue

		exit_data = self.choose_exit(new_room, room_placement_pos)

		if exit_data.empty():
			#print("\tNo Available Exits!")
			continue

		var next_exit : Dictionary = {"exit": exit_data.exit, "to": exit_data.to}

		new_room["exits"] = [next_exit]
		new_room["exits"].append(return_exit_info)
		previous_room.exit_data["entrance"] = return_exit_info.exit
		map_data[previous_room.pos.x][previous_room.pos.y].node.exits.erase(previous_room.exit_data.exit)

		created_rooms += 1
		new_room["map_position"] = room_placement_pos
		new_room["rank"] = path_rank
		rooms_list.append(new_room)
		self.place_room(new_room)

		previous_room.exit_data = next_exit
		previous_room.exit_dir = exit_data.dir
		previous_room.pos = room_pos

		room_pos = exit_data.to

		$Room_Manager.prepare_room_list(room_types.NORMAL, previous_room.exit_dir)

	#Adding Power Room
	var final_room = make_special_room(room_pos, final_room_type, previous_room)

	final_room.room["rank"] = path_rank
	rooms_list.append(final_room.room)
	return rooms_list

func make_special_room(position : Vector2, type : int, from : Dictionary = {}) -> Dictionary:
	var new_room_data : Dictionary = {"room":{}, "exit":{}}

	$Room_Manager.prepare_room_list(type)

	match(type):

		room_types.START:
			new_room_data.room["node"] = $Room_Manager.get_room()
			new_room_data.room.node.exits.shuffle()
			new_room_data.room["map_position"] = position

			var exit_data = choose_exit(new_room_data.room, position)
			var exit = {"exit":exit_data.exit, "to": exit_data.to}

			new_room_data.room["exits"] = [exit]

			new_room_data.exit["dir"] = exit_data.dir
			new_room_data.exit["to"] = exit_data.to
			new_room_data.exit["pos"] = position
			new_room_data.exit["exit"] = exit

			place_room(new_room_data.room)

		room_types.POWER, room_types.BONUS:
			new_room_data.room["node"] = $Room_Manager.get_room()

			for entrance in new_room_data.room.node.exits:
				if entrance.direction == from.exit_dir:

					var room_placement_pos = position - entrance.position
					var fits = true

					for pos in new_room_data.room.node.room_positions:
						var map_pos : Vector2 = room_placement_pos + pos
						if map_pos.x < 0 or map_pos.x >= MAP_SIZE.x or \
						   map_pos.y < 0 or map_pos.y >= MAP_SIZE.y or \
						   map_data[map_pos.x][map_pos.y] != null:
							print("\tDoesn't fit because of "+str(map_pos))
							fits = false
							break

					if fits:
						from.exit_data["entrance"] = entrance
						map_data[from.pos.x][from.pos.y].node.exits.erase(from.exit_data)
						new_room_data.room["map_position"] = room_placement_pos
						new_room_data.room["exits"] = [{"exit": entrance, "to": from.pos, "entrance": from.exit_data.exit}]
						new_room_data.room.node.exits.erase(entrance)
						break

			place_room(new_room_data.room)

		room_types.GATE:
			while true:
				new_room_data.room["node"] = $Room_Manager.get_room()

				if new_room_data.room["node"] == null:
					print("Gate Queue Empty!")
					new_room_data = {}
					break

				var fits = false
				var room_placement_pos : Vector2
				var return_exit : Dictionary

				new_room_data.room.node.exits.shuffle()

				for entrance in new_room_data.room.node.exits:
					if entrance.direction == from.exit_dir:

						room_placement_pos = position - entrance.position
						fits = true

						for pos in new_room_data.room.node.room_positions:
							var map_pos : Vector2 = room_placement_pos + pos
							if map_pos.x < 0 or map_pos.x >= MAP_SIZE.x or \
							   map_pos.y < 0 or map_pos.y >= MAP_SIZE.y or \
							   map_data[map_pos.x][map_pos.y] != null:
								#print("\tDoesn't fit because of "+str(map_pos))
								fits = false
								break

						if fits:
							new_room_data.room.node.exits.erase(entrance)
							return_exit = {"exit": entrance, "to": from.pos, "entrance": from.exit_data.exit}
							break

				if not fits:
					continue

				var exit_data = choose_exit(new_room_data.room, room_placement_pos)

				if exit_data.empty():
					continue

				var exit = {"exit":exit_data.exit, "to": exit_data.to}

				from.exit_data["entrance"] = return_exit.exit
				map_data[from.pos.x][from.pos.y].node.exits.erase(from.exit_data)

				new_room_data.room["map_position"] = room_placement_pos
				new_room_data.room["exits"] = [return_exit, exit]

				new_room_data.exit["dir"] = exit_data.dir
				new_room_data.exit["to"] = exit_data.to
				new_room_data.exit["pos"] = room_placement_pos
				new_room_data.exit["exit"] = exit

				place_room(new_room_data.room)
				break

	return new_room_data

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

			exit_data["exit"] = exit
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

		for exit_data in cur_room.exits:
			if exit_data.exit.id == exit_id:
				change_room(exit_data.to, exit_data.entrance.position)
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
