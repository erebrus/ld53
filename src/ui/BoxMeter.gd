extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var icon_parent = $Icons
var icons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	icons = icon_parent.get_children()
	Globals.connect("new_package", self, "on_package_change")
	Globals.connect("package_change", self, "on_package_change")

func on_package_change(free_anchor_count):
#	print("FREE ANCHOR COUNT")
#	print(free_anchor_count)
	for i in 6:
		icons[i].fill()
	for i in free_anchor_count:
		icons[icons.size() - 1 - i].clear()
