extends Node2D

var room_list : Array = []

var start_rooms : Dictionary = {"list":[], "pointer":0}
var normal_rooms : Dictionary = {"list":[], "pointer":0}
var power_rooms : Dictionary = {"list":[], "pointer":0}

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
				normal_rooms.list.append(room)

			room.room_types.START:
				start_rooms.list.append(room)

			room.room_types.POWER:
				power_rooms.list.append(room)

	#normal_rooms.list.shuffle()
	#start_rooms.list.shuffle()
	#power_rooms.list.shuffle()

func get_room() -> Dictionary:
	if rand_range(0, 1) > 0.5:
		return normal_rooms.list[0].get_data()
	else:
		return normal_rooms.list[1].get_data()

func free():
	for room in room_list:
		room.call_deferred("free")

	.free()
