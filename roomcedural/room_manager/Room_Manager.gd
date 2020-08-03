extends Node2D

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS}

var room_list : Array = []

var start_rooms : Dictionary = {"list":[], "pointer":0}
var normal_rooms : Dictionary = {exit_dir.UP:[], exit_dir.DOWN:[], exit_dir.LEFT:[], exit_dir.RIGHT:[]}
var power_rooms : Dictionary = {"list":[], "pointer":0}

var room_queue : Dictionary = {"list":[], "pointer":0}

func _ready():
	var path = "res://roomcedural/room_manager/rooms/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			#print("Found Room: " + file_name)
			room_list.append(load(path+file_name).instance())
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the rooms folder.")

	for room in room_list:
		match(room.room_type):

			room.room_types.NORMAL:
				if exit_dir.UP in room.exit_directions:
					normal_rooms[exit_dir.UP].append(room)

				if exit_dir.DOWN in room.exit_directions:
					normal_rooms[exit_dir.DOWN].append(room)

				if exit_dir.LEFT in room.exit_directions:
					normal_rooms[exit_dir.LEFT].append(room)

				if exit_dir.RIGHT in room.exit_directions:
					normal_rooms[exit_dir.RIGHT].append(room)

			room.room_types.START:
				start_rooms.list.append(room)

			room.room_types.POWER:
				power_rooms.list.append(room)

	room_queue.list = normal_rooms[exit_dir.UP]
	room_queue.list.shuffle()
	start_rooms.list.shuffle()
	#power_rooms.list.shuffle()

func prepare_room_list(type: int, dir : int = exit_dir.UP) -> void:
	match(type):

		room_types.START:
			room_queue.list = start_rooms.list

		room_types.NORMAL:
			room_queue.list = normal_rooms[dir]

	room_queue.list.shuffle()
	room_queue.pointer = 0

func get_room():
	if room_queue.pointer >= room_queue.list.size():
		return null

	var data = room_queue.list[room_queue.pointer].get_data()
	room_queue.pointer += 1

	return data

func free():
	for room in room_list:
		room.call_deferred("free")

	.free()
