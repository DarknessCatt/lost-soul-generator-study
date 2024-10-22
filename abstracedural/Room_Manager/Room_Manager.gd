extends Node2D

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS, GATE}

var room_list : Array = []

var start_rooms : Array = []
var normal_rooms : Dictionary = {exit_dir.UP:[], exit_dir.DOWN:[], exit_dir.LEFT:[], exit_dir.RIGHT:[]}
var power_rooms : Array = []
var bonus_rooms : Array = []
var gate_rooms : Array = []

var room_queue : Dictionary = {"list":[], "pointer":0}

func _ready():
	var path = "res://abstracedural/Rooms/"
	var dir = Directory.new()

	#Pega todos os arquivos .tscn no caminho
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if ".tscn" in file_name:
				room_list.append(load(path+file_name).instance())
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the rooms folder.")

	#Organiza os quartos
	for room in room_list:
		match(room.room_type):

			room.room_types.NORMAL:
				for exit in room.exits:
					match(exit.direction):

						exit_dir.UP:
							if not room in normal_rooms[exit_dir.UP]:
								normal_rooms[exit_dir.UP].append(room)

						exit_dir.DOWN:
							if not room in normal_rooms[exit_dir.DOWN]:
								normal_rooms[exit_dir.DOWN].append(room)

						exit_dir.LEFT:
							if not room in normal_rooms[exit_dir.LEFT]:
								normal_rooms[exit_dir.LEFT].append(room)

						exit_dir.RIGHT:
							if not room in normal_rooms[exit_dir.RIGHT]:
								normal_rooms[exit_dir.RIGHT].append(room)

			room.room_types.START:
				start_rooms.append(room)

			room.room_types.POWER:
				power_rooms.append(room)

			room.room_types.BONUS:
				bonus_rooms.append(room)

			room.room_types.GATE:
				gate_rooms.append(room)

#	print("Room Direction Distribution:")
#	print("UP: "+str(normal_rooms[exit_dir.UP].size()))
#	print("DOWN: "+str(normal_rooms[exit_dir.DOWN].size()))
#	print("LEFT: "+str(normal_rooms[exit_dir.LEFT].size()))
#	print("RIGHT: "+str(normal_rooms[exit_dir.RIGHT].size()))

func prepare_room_list(type: int, dir : int = exit_dir.UP) -> void:
	match(type):

		room_types.START:
			room_queue.list = start_rooms

		room_types.NORMAL:
			room_queue.list = normal_rooms[dir]

		room_types.POWER:
			room_queue.list = power_rooms

		room_types.BONUS:
			room_queue.list = bonus_rooms

		room_types.GATE:
			room_queue.list = gate_rooms

	room_queue.list.shuffle()
	room_queue.pointer = 0

func get_room():
	if room_queue.pointer >= room_queue.list.size():
		return null

	var data = room_queue.list[room_queue.pointer].duplicate()
	room_queue.pointer += 1

	return data

func free():
	for room in room_list:
		room.call_deferred("free")

	.free()
