extends CanvasLayer


func _ready() -> void:
	Globals.connect("survived", self, "show_win")
	Globals.connect("game_over", self, "show_lose")


func show_win():
	$Win.show()
	$sfx_win.play()
	fade()
	
func show_lose():
	$Lose.show()
	$sfx_lose.play()
	fade()

		
func fade():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var panel = $Panel	
	tween.tween_property(panel, "color", Color.black, 5)
	yield(tween,"finished")
	get_tree().change_scene("res://src/ui/MainMenu.tscn")
