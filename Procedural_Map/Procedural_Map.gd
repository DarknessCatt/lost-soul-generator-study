extends Node2D

const ROOM_RES = preload("res://Rooms/Rooms.tscn")
const ROOM_SIZE = 8
const MAP_SIZE = 10

const PATH_NUM = 6
const PATH_MIN = 3

const BRANCH_NUM = 4
const BRANCH_SIZE = 4

var directions = ["down", "up", "left", "right"]
var map : Array = []

func _ready():
	randomize()
	var rooms : Node2D = ROOM_RES.instance()
	rooms._ready()

	for x in range(MAP_SIZE):
		map.append([])
		for _y in range(MAP_SIZE):
			map[x].append(null)

	var error_count : int = 0
	var full_map : Array = []

	while error_count < 10:
		var room_list : Array = make_path(Vector2.ZERO, "up", PATH_NUM)

		if room_list.size() >= PATH_MIN:
			error_count = 0
			full_map.append(room_list)
			break

		error_count += 1

	if error_count == 10:
		print("aborting")
		return

	while error_count < 10:
		var rand_start = randi()%(full_map[0].size()-1)
		var missing_rooms = (PATH_NUM - full_map[0].size())
		var room_list : Array = make_path(full_map[0][rand_start].pos, "up", PATH_NUM+missing_rooms)

		if room_list.size() >= PATH_MIN + missing_rooms + 1:
			error_count = 0
			var branch_map : Dictionary = room_list.pop_front()
			full_map[0][rand_start].entrances.append(branch_map.entrances[1])
			full_map.append(room_list)
			break

		error_count += 1

	if error_count == 10:
		print("aborting 2")
		return

	var branch_list = []

	for _num in range(BRANCH_NUM):
		var rand_path = full_map[randi()%(full_map.size())]
		var rand_start = randi()%(rand_path.size()-1)

		var room_list : Array = make_path(rand_path[rand_start].pos, "up", BRANCH_SIZE)

		if room_list.size() > 2:
			error_count = 0
			var branch_map : Dictionary = room_list.pop_front()
			rand_path[rand_start].entrances.append(branch_map.entrances[1])
			branch_list.append(room_list)

	for room_info in full_map[0]:
		copy_room($Map_Part1, room_info.pos*ROOM_SIZE, rooms.get_room(room_info.entrances))

	for room_info in full_map[1]:
		copy_room($Map_Part2, room_info.pos*ROOM_SIZE, rooms.get_room(room_info.entrances))

	for branch_path in branch_list:
		for room_info in branch_path:
			copy_room($Map_Part3, room_info.pos*ROOM_SIZE, rooms.get_room(room_info.entrances))

func make_path(initial_pos : Vector2, initial_from : String, max_size : int) -> Array:
	var room_list = []
	var room_pos = initial_pos
	var from = initial_from
	var complete : bool = false

	var num : int = 0
	while num < max_size-1:
		var dir = get_random_dir(room_pos)

		if dir == "":
			room_list.append({"pos" : room_pos, "entrances" : []})
			complete = true
			break

		else:
			map[room_pos.x][room_pos.y] = [from, dir]

			room_list.append({"pos" : room_pos, "entrances" : [from, dir]})
			num += 1

			match dir:
				"up":
					from = "down"
					room_pos.y -= 1

				"down":
					from = "up"
					room_pos.y += 1

				"right":
					from = "left"
					room_pos.x += 1

				"left":
					from = "right"
					room_pos.x -= 1

	if not complete:
		map[room_pos.x][room_pos.y] = []
		room_list.append({"pos" : room_pos, "entrances" : []})

	return room_list

func get_random_dir(pos : Vector2) -> String:
	directions.shuffle()

	for dir in directions:
		match dir:
			"up":
				if (pos.y - 1) >= 0 and map[pos.x][pos.y - 1] == null:
					return "up"

			"down":
				if (pos.y + 1) < MAP_SIZE and map[pos.x][pos.y + 1] == null:
					return "down"

			"right":
				if (pos.x + 1) < MAP_SIZE and map[pos.x + 1][pos.y] == null:
					return "right"

			"left":
				if (pos.x - 1) >= 0 and map[pos.x - 1][pos.y] == null:
					return "left"

	return ""


func copy_room(tilemap : TileMap, pos : Vector2, room : Array) -> void:
	for tile_info in room:
		var tile_pos = tile_info[0] + pos
		tilemap.set_cell(tile_pos.x, tile_pos.y, tile_info[1])
