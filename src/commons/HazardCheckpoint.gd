extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("player"):
		Globals.emit_signal("on_checkpoint", global_position)		
