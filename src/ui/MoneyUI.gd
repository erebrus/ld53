extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var total_label = $Total
onready var added_label = $Added
onready var anim_player = $AnimationPlayer
var current_money = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	total_label.text = "$" + str(current_money)
	added_label.text = ""
	Globals.connect("gain_money", self, "on_money_gain")

func on_money_gain(current, extra):
	current_money = current + extra
	added_label.text = str(extra)
	if extra > 0:
		added_label.text = "+" + added_label.text
		anim_player.play("Add")
	else:
		added_label.text = "-" + added_label.text
		anim_player.play("Subtract")
	
func on_extra_anim_done():
	total_label.text = "$" + str(current_money)
	
