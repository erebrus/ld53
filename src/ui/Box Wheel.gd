extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slots = []
var last_selected = 0 
var selected = 0
var max_slots = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	slots = get_children()
	slots[selected].select()

func show_wheel(packages):
	visible = true
	for i in max_slots:
		slots[i].fill_slot(packages[i])
		
func hide_wheel():
	visible = false
	pass

func change_selection():
	slots[last_selected].un_select()
	slots[selected].select()

func _process(delta: float) -> void:
	last_selected = selected
	if Input.is_action_just_pressed("ui_left"):
		if last_selected == 0:
			selected = max_slots - 1
		else:
			selected -= 1
		change_selection()
	elif Input.is_action_just_pressed("ui_right"):
		if last_selected == max_slots - 1:
			selected = 0
		else:
			selected += 1
		change_selection()
