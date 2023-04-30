extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bubble_text = ""
var bubble_text_length = 0
var bubble_text_index = 0
var current_text = ""

onready var label = $VBoxContainer/Label
onready var rect = $VBoxContainer/Label/NinePatchRect
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
var close = false
# Called when the node enters the scene tree for the first time.
func _ready():
	#bubble_text_length = bubble_text.length()
	#timer.start(1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func open_dialog(text: String):
	close = false
	bubble_text = text
	bubble_text_length = bubble_text.length()
	bubble_text_index = 0
	current_text = ""
	anim_player.play("Open")
	timer.start(.5)
	
func close_dialog():
	bubble_text = ""
	anim_player.play("Close")

func _on_Timer_timeout():
	if !close:
		current_text += bubble_text[bubble_text_index]
		label.text = current_text
		
		if bubble_text_index < bubble_text_length - 1:
			timer.start(.04)
			bubble_text_index += 1
		else:
			if !close:
				close = true
				timer.start(1)
	else:
		if bubble_text_length > 0:
			current_text.erase(bubble_text_length - 1, 1)
			label.text = current_text
			bubble_text_length -= 1
			
			timer.start(.01)
		else:
			close_dialog()
