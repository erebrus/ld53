extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var label = $Label
var current_seconds = 32400
var time_since_beginning = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.time.connect("tick_ended", self, "on_tick_ended")
	Globals.time.connect("cycle_ended", self, "on_cycle_ended")

func on_tick_ended():
	time_since_beginning += 1
	current_seconds += 60
	label.text = convert_to_clock(current_seconds)
	if time_since_beginning % 30 == 0:
		$AnimationPlayer.play("SPECIAL")

func convert_to_clock(seconds):
	var minutes = (seconds/60)%60
	var hours = (seconds/60)/60
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d" % [hours, minutes]

func on_cycle_ended():
	pass
	#$AnimationPlayer.play("SPECIAL")
