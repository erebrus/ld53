tool
extends StateAnimation


#
# FUNCTIONS TO INHERIT IN YOUR STATES
#

# This additionnal callback allows you to act at the end
# of an animation (after the nb of times it should play)
# If looping, is called after each loop
func _on_anim_finished(_name: String) -> void:
	change_state()


# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	if owner.controller:
		owner.controller.air_jump_count = 0

# This function is called just after the state enters
# XSM after_enters the children first, then the parent
func _after_enter(_args) -> void:
	pass


# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if owner.disabled:
		return
	#player isn't moving
	if abs(input.x) >.1:
		change_state("Walk")
		return
		
	owner.velocity.x=0
	Logger.trace("idle x mov")
	
	if owner.controller.processing_jump:
	#if Input.is_action_just_pressed("jump"):		
		Logger.debug("Press jump in idle")
		owner.controller.do_jump()


# This function is called each frame after all the update calls
# XSM after_updates the children first, then the root
func _after_update(_delta: float) -> void:
	pass


# This function is called before the State exits
# XSM before_exits the root first, then the children
func _before_exit(_args) -> void:
	pass


# This function is called when the State exits
# XSM before_exits the children first, then the root
func _on_exit(_args) -> void:
	pass


# when StateAutomaticTimer timeout()
func _state_timeout() -> void:
	pass


# Called when any other Timer times out
func _on_timeout(_name) -> void:
	pass
