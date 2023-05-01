extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var anim_player = $AnimationPlayer
onready var box = $Box
var target_name = ""
var target_section = ""
var is_empty = true

func fill_slot(incoming):
	if incoming != null:
		target_name = incoming.target_name
		target_section = incoming.target_section
		is_empty = false
		box.visible = true
	else:
		clear_slot()
	
func clear_slot():
	target_name = ""
	target_section = ""
	is_empty = true
	box.visible = false
	anim_player.play("Unselected")
	pass
func select():
	if is_empty:
		return
	anim_player.play("Selected")
	
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
