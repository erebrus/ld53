tool
extends StateAnimation


func _on_anim_finished(_name: String) -> void:
	change_state("Idle")
