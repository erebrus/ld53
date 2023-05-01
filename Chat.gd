extends Node2D

signal done

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
export var requires_keypress:=false
var done:=false
# Called when the node enters the scene tree for the first time.
func _ready():
	#bubble_text_length = bubble_text.length()
	#timer.start(1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func open_dialog(text: String, manual:bool = false):
	done=false
	requires_keypress = manual
	close = false
	label.text = ""
	bubble_text = text
	bubble_text_length = bubble_text.length()
	bubble_text_index = 0
	current_text = ""
	
	anim_player.play("Open")
	timer.start(.5)
	
func close_dialog():
	bubble_text = ""
	current_text = ""
	bubble_text_length = 0
	label.text = ""
	anim_player.play("Close")
	requires_keypress = false
	emit_signal("done")

func _is_done()->bool:
	return not(bubble_text_index < bubble_text_length - 1) and done

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ask"):
		if requires_keypress and not close:
			 close_dialog()

func _on_Timer_timeout():
	if !close:
		if bubble_text_index>=bubble_text.length():
			close=true
			bubble_text_index=0
			_on_Timer_timeout()
			return
		current_text += bubble_text[bubble_text_index]
		label.text = current_text
		
		if bubble_text_index < bubble_text_length - 1:
			timer.start(.04)
			bubble_text_index += 1
		else:
			if not done:
				emit_signal("done")
				done=true
			if !close:
				close = true
#				if not requires_keypress:
				timer.start(2)
	else:
		if bubble_text_length > 0:
			current_text.erase(bubble_text_length - 1, 1)
			label.text = current_text
			bubble_text_length -= 1
			
			timer.start(.01)
		else:
			close_dialog()
