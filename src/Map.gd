extends Node2D

	
func _on_Timer_timeout() -> void:
	Globals.time.tick()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Globals.emit_signal("game_over")
