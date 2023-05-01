extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var package: Package = null
onready var anim_player = $AnimationPlayer
onready var box = $Box
onready var chat = $Chat


func fill_slot(box):
	package = box
	box.visible = true
func clear_slot():
	package = null
	box.visible = false
	pass
func select():
	anim_player.play("Selected")
	var format_string = "Name: %s\nSection: %s"
	var text = format_string % [package.target_name, package.target_section]
	chat.open_dialog(text)
func un_select():
	anim_player.play("Unselected")
	
func deliver():
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Selected":
		anim_player.play("Selected Loop")
