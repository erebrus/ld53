extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var chat = $Chat
var hide = true
var slots = []
var last_selected = 0 
var selected = 0
var max_slots = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	slots = get_children()
	slots[selected].select()
	if hide:
		hide_wheel()

func show_wheel(packages):
	selected = 0
	hide = false
	visible = true
	var filled_i = 0
	for i in max_slots:
		slots[i].clear_slot()
		if packages[i] == null:
			continue
		slots[filled_i].fill_slot(packages[i])
		filled_i += 1
	if filled_i > 0:
		slots[selected].select()
		show_tooltip()
		
func hide_wheel():
	hide = true
	visible = false
	for i in max_slots:
		slots[i].un_select()

func change_selection():
	if !slots[selected].is_empty:
		slots[last_selected].un_select()
		slots[selected].select()
		show_tooltip()
	else:
		selected = last_selected
	
func show_tooltip():
	if !slots[selected].is_empty:
		var target_name = slots[selected].target_name
		var target_section = slots[selected].target_section
		var format_string = "Name: %s\nSection: %s"
		var text = format_string % [target_name, target_section]
		chat.open_dialog(text)

func get_selection():
	return selected
	
func clear_selection():
	slots[selected].clear_slot()

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
