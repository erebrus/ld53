extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var label = $Label
var current_seconds = 32400

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.time.connect("tick_ended", self, "on_tick_ended")

func on_tick_ended():
	current_seconds += 60
	label.text = convert_to_clock(current_seconds)

func convert_to_clock(seconds):
	var minutes = (seconds/60)%60
	var hours = (seconds/60)/60
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d" % [hours, minutes]
