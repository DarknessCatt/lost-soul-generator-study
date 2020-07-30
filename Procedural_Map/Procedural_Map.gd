extends Node2D

enum {DOWN, UP, RIGHT, LEFT}

const ROOM_RES = preload("res://Rooms/Rooms.tscn")
const ROOM_SIZE = 8
const MAP_SIZE = 4
const MAP_NUM = 6


var directions = [DOWN, UP, RIGHT, LEFT]
var map : Array = []

func _ready():
	randomize()
	var rooms : Node2D = ROOM_RES.instance()

	for x in range(MAP_SIZE):
		map.append([])
		for y in range(MAP_SIZE):
			map[x].append(null)

	var room_list = []
	var room_pos = Vector2.ZERO
	var from = UP

	for num in range(MAP_NUM):
		var dir = get_random_dir(room_pos)

		if dir == -1:
			break

		map[room_pos.x][room_pos.y] = {from = from, dir = dir}
		room_list.append({from = from, dir = dir, pos = room_pos})

		match dir:
			UP:
				from = DOWN
				room_pos.y -= 1

			DOWN:
				from = UP
				room_pos.y += 1

			RIGHT:
				from = LEFT
				room_pos.x += 1

			LEFT:
				from = RIGHT
				room_pos.x -= 1

	for room_info in room_list:
		copy_room(room_info.pos*ROOM_SIZE, rooms.get_room(room_info.from, room_info.dir))

	#copy_room(room_pos*ROOM_SIZE, rooms.get_room(0))

func get_random_dir(pos : Vector2) -> int:
	directions.shuffle()

	for dir in directions:
		match directions[dir]:
			UP:
				if (pos.y - 1) >= 0 and map[pos.x][pos.y - 1] == null:
					return UP

			DOWN:
				if (pos.y + 1) < MAP_SIZE and map[pos.x][pos.y + 1] == null:
					return DOWN

			RIGHT:
				if (pos.x + 1) < MAP_SIZE and map[pos.x + 1][pos.y] == null:
					return RIGHT

			LEFT:
				if (pos.x - 1) >= 0 and map[pos.x - 1][pos.y] == null:
					return LEFT

	return -1


func copy_room(pos : Vector2, room : Array) -> void:
	for tile_info in room:
		var tile_pos = tile_info[0] + pos
		$Map.set_cell(tile_pos.x, tile_pos.y, tile_info[1])
