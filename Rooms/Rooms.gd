extends Node2D

var room_tree : Dictionary = \
{
	"atr" : "down",
	"has" : {
		"atr" : "up",
		"has" : {
			"atr" : "left",
			"has" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			},
			"hasnt" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			}
		},
		"hasnt" : {
			"atr" : "left",
			"has" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			},
			"hasnt" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			}
		}
	},
	"hasnt" : {
		"atr" : "up",
		"has" : {
			"atr" : "left",
			"has" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			},
			"hasnt" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			}
		},
		"hasnt" : {
			"atr" : "left",
			"has" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			},
			"hasnt" : {
				"atr" : "right",
				"has" : [],
				"hasnt" : []
			}
		}
	}
}

func _ready():
	for room in get_children():
		var tree = room_tree

		while typeof(tree) == TYPE_DICTIONARY:
			if room.get(tree["atr"]):
				tree = tree["has"]
			else:
				tree = tree["hasnt"]

		tree.append(room)


func get_room(entrances : Array) -> Array:
	var data := []

	var tree = room_tree

	for dir in ["down", "up", "left", "right"]:
		if entrances.has(dir):
			tree = tree["has"]
		else:
			tree = tree["hasnt"]

	tree.shuffle()
	var room = tree.front()

	for v in room.get_used_cells():
		data.append([v, room.get_cellv(v)])

	return data
