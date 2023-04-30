extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var number = $Number
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
var current_level = 0
var anim = "1"

func change_sign(level):
	if level != current_level:
		current_level = level
		match level:
			0:
				anim = "1"
			1:
				anim = "2"
			2: 
				anim = "3"
			3:
				anim = "4"
			4: 
				anim = "5"
			5:
				anim = "6"
		anim_player.seek(0)
		anim_player.play("Change")
	
			

# Called when the node enters the scene tree for the first time.
func _ready():
	number.play(anim)
	pass # Replace with function body.



func switch_number():
	number.play(anim)

func switch_complete():
	anim_player.play("Idle")

