extends Node2D

class_name Base_Room

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS}

export(room_types) var room_type : int = room_types.NORMAL
export(Array, Vector2) var room_positions : Array = [Vector2(0,0)]
export(Array, Resource) var exits : Array = []

signal player_exited(exit)

func _ready():
	for exit in exits:
		assert(exit.position in room_positions)

func open_exits(_exits : Array):
	pass
