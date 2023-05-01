extends Area2D



func _on_body_entered(body: Node) -> void:
	if body.has_method("slip"):
		body.slip()
		queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
