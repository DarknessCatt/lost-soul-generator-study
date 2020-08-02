extends Node2D

enum exit_dir {UP, DOWN, LEFT, RIGHT}
enum room_types {START, NORMAL, POWER, BONUS}

export(room_types) var room_type : int = room_types.NORMAL
export(Array, Vector2) var room_position : Array = [Vector2(0,0)]
export(Array, int, "Up", "Down", "Left", "Right") var exit_directions : Array
export(Array, Vector2) var exit_positions : Array

func _ready():
	assert(exit_directions.size() == exit_positions.size())

	for exit_pos in exit_positions:
		assert(exit_pos in room_position)

func get_data() -> Dictionary:
	var data : Dictionary = {"positions": [], "tiles" : [], "exits": []}

	for pos in room_position:
		data.positions.append(pos)

	for i in range(exit_directions.size()):
		data.exits.append([exit_positions[i], exit_directions[i]])

	for tile in $Tileset.get_used_cells():
		data.tiles.append([tile, $Tileset.get_cellv(tile)])

	return data
