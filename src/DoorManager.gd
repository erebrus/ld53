extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim_player = $AnimationPlayer
onready var timer = $Timer
onready var tween = $Tween
var stairs_duration = 1
var doors = []
var player = null
var busy = false
var destination = 0

enum DoorState {INACTIVE, OPEN_FIRST, OPEN_SECOND}
var state = DoorState.INACTIVE
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	doors = get_children()
	Globals.connect("go_up_floor", self, "go_up_floor")
	Globals.connect("go_down_floor", self, "go_down_floor")

func go_up_floor(current, target):
	if state == DoorState.INACTIVE:
		do_floor_transition(current - 1, target - 1)

func go_down_floor(current, target):
	if state == DoorState.INACTIVE:
		do_floor_transition(current - 1, target - 1)
	
func do_floor_transition(current, target):
	state = DoorState.OPEN_FIRST
	destination = target
	player.disabled = true
	tween.stop(player)
	tween.interpolate_property(player, "global_position", player.global_position, doors[destination].position, stairs_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	doors[current].open_door()
	anim_player.play("Enter Stairs")
	timer.start(stairs_duration)
	
func _on_Timer_timeout():
	if state == DoorState.OPEN_FIRST:
		state = DoorState.OPEN_SECOND
		doors[destination].open_door()
		timer.start(.1)
	else:
		state = DoorState.INACTIVE
		player.position = doors[destination].position
		player.disabled = false
		anim_player.play("Leave Stairs")
