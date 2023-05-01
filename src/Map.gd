extends Node2D

#func _ready() -> void:
#	yield(get_tree().create_timer(3), "timeout")
#	Globals.emit_signal("game_over")
	
func _on_Timer_timeout() -> void:
	Globals.time.tick()
	
