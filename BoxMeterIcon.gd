extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var empty = $Empty
onready var filled = $Filled

# Called when the node enters the scene tree for the first time.
func _ready():
	clear()

func fill():
	empty.visible = false
	filled.visible = true
	
func clear():
	empty.visible = true
	filled.visible = false
