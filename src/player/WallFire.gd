tool
extends StateAnimation


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _on_enter(_args) -> void:
	
	owner.sfx_fire.play()	
	owner.emit_signal("fired")	
	owner.set_attack_box_enabled(true)
	owner.can_attack = false
	owner.reload_timer.start()	
	yield(get_tree().create_timer(.2),"timeout")
	owner.set_attack_box_enabled(false)

func _on_update(_delta: float) -> void:
		owner.velocity.y=0
