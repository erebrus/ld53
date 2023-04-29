extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var seek = rng.randf_range(0, 2)
	tree.set("parameters/Idle/Seek/seek_position", seek)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
