extends Node2D

func _ready() -> void:
	Globals.connect("survived", self, "on_game_over")
	Globals.connect("game_over", self, "on_game_over")
		
func _on_Timer_timeout() -> void:
	Globals.time.tick()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Globals.emit_signal("game_over")


func on_game_over():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($Music, "volume_db", -80, 5)

