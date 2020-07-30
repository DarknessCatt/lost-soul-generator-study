extends Node2D

const ROOM_RES = preload("res://Rooms/Rooms.tscn")
const ROOM_SIZE = 8
const MAP_SIZE = 10
const MAP_NUM = 50


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

	var room_list = []
	var room_pos = Vector2.ZERO
	var from = "up"
	var backtrack : int = -1
	var errors : int = 0

	var num : int = 0
	while num < MAP_NUM:
		var dir = get_random_dir(room_pos)

		if dir == "":
			errors += 1
			if errors > 40:
				print("stuck too much, aborting")
				break

			print("stuck, backtracking")
			backtrack = randi()%room_list.size()
			room_pos = room_list[backtrack].pos
			continue

		else:
			map[room_pos.x][room_pos.y] = [from, dir]

			if backtrack == -1:
				room_list.append({"pos" : room_pos, "entrances" : [from, dir]})
				num += 1

			else:
				room_list[backtrack].entrances.append(dir)
				backtrack = -1

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

	print(room_list.size())

	for room_info in room_list:
		copy_room(room_info.pos*ROOM_SIZE, rooms.get_room(room_info.entrances))

	#copy_room(room_pos*ROOM_SIZE, rooms.get_room(0))

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


func copy_room(pos : Vector2, room : Array) -> void:
	for tile_info in room:
		var tile_pos = tile_info[0] + pos
		$Map.set_cell(tile_pos.x, tile_pos.y, tile_info[1])
