extends Control

export(PackedScene) var first_level:PackedScene

onready var sfx_select:=$sfx_select
onready var sfx_press:=$sfx_press
onready var sfx_quit_press:=$sfx_quit_press

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(first_level)
	Globals.start_music()


func _on_Start_pressed():
	if sfx_press.stream:
		sfx_select.stop()
		sfx_press.play()
		yield(get_tree().create_timer(.8),"timeout")
	Globals.lives=null
	get_tree().change_scene_to(first_level)

func _on_Quit_pressed():
	if sfx_quit_press.stream:
		sfx_select.stop()
		sfx_quit_press.play()
		yield(get_tree().create_timer(.8),"timeout")
	get_tree().quit()


func _on_mouse_entered():
	sfx_select.play()



