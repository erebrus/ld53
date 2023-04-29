tool
extends StateAnimation


#
# FUNCTIONS TO INHERIT IN YOUR STATES
#

# This additionnal callback allows you to act at the end
# of an animation (after the nb of times it should play)
# If looping, is called after each loop
func _on_anim_finished(_name: String) -> void:
	pass


# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
		#set coyote timer
#		pass
	if owner.velocity.y>0.01 and !owner.is_on_floor() and owner.controller.coyote_time>0 and owner.controller.landed:
		owner.controller.accept_coyote_jump=true
		get_tree().create_timer(owner.controller.coyote_time).connect("timeout", owner.controller, "reset_coyote_time")


# This function is called just after the state enters
# XSM after_enters the children first, then the parent
func _after_enter(_args) -> void:
	pass


# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	
	if owner.is_on_wall() and not owner.is_on_floor() and owner.controller.can_climb:
		change_state("Climb")
		return
		
	if owner.is_on_floor():
		if abs(owner.velocity.x)<1:
			owner.velocity.x=0
		if owner.controller.jump_requested and owner.controller.jump_available: #jump buffer
			owner.controller.do_jump()
		else:
			owner.on_landing(owner.last_y)
		owner.controller.jump_available=true
		if owner.velocity.x != 0:
			change_state("Walk")
		else:
			change_state("Idle")
		return
	else:
		if owner.controller.processing_jump:
		#if Input.is_action_just_pressed("jump"):
			Logger.debug("Press jump in fall")
			if owner.controller.air_jump_count < owner.controller.max_air_jumps or owner.controller.is_in_coyote_time():
				Logger.debug("coyote %s jump count %d" % [owner.controller.is_in_coyote_time(), owner.controller.air_jump_count])
				owner.controller.do_jump()	
			else:
				Logger.debug("Rejected air jump. count=%d, max=%d. coyote=%s " % [owner.controller.air_jump_count, owner.controller.max_air_jumps, owner.controller.is_in_coyote_time()])
				owner.controller.jump_requested=true
				get_tree().create_timer(owner.controller.jump_buffer).connect("timeout",owner.controller,"reset_jump_buffer")				





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
