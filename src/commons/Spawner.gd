extends Node2D

export(PackedScene) var enemy_scene:PackedScene

export(int) var init_delay=2
export(int) var min_time:=3
export(int) var max_time:=7

onready var timer:Timer = $Timer


func _ready() -> void:
	assert(enemy_scene)
	yield(get_tree(), "idle_frame")
	if init_delay:
		timer.wait_time=init_delay
		timer.start()
	else:
		spawn()
		

func spawn():
	
	var e = enemy_scene.instance()
	var node = get_parent()
	node.add_child(e)	
	e.global_position = global_position
	Logger.info("%s - Spawned at %s " % [name, e.global_position])


func _on_Timer_timeout() -> void:
	spawn()
	timer.wait_time = RNGTools.randi_range(min_time, max_time)	
	timer.start()
		
