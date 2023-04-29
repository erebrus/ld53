extends Area2D

export var new_scene:PackedScene
export var signal_name:String
# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _on_TransitionArea_body_entered(body):
	if body.is_in_group("player"):
		if new_scene:
			get_tree().change_scene_to(new_scene)
		if signal_name:
			Globals.emit_signal(signal_name)
