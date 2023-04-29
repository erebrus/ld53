tool
extends StateAnimation


var collision_direction:Vector2
var t
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
#		Logger.info("Climb collision count=%d" % owner.get_slide_count())
#		for i in owner.get_slide_count():
#			Logger.info("Collision %d - %s" % [i, owner.get_slide_collision(i).normal])
		var collision = owner.get_slide_collision(0)
		if not collision:
			change_state("Idle")
			Logger.info("no collision for climb!")
			return
		collision_direction = -collision.normal
#		t = add_timer("climb_hangtime",owner.controller.climb_timeout)
		var input = Input.get_vector("ui_left", "ui_right", "", "")
		Logger.debug("Entering climb because direction %2f vs %2f " % [input.x, collision_direction.x])


# This function is called just after the state enters
# XSM after_enters the children first, then the parent
func _after_enter(_args) -> void:
	pass


# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input.y>0:
		Logger.debug("Stop Climb because of direction (%sd vs %2f )" % [input, collision_direction.x])
		change_state("Fall")
	elif not owner.is_climb_rc_colliding():	
	#if sign(input .x) != sign(collision_direction.x) or not owner.is_climb_rc_colliding():		
		Logger.debug("Stop Climb because RC (%sd vs %2f )" % [input, collision_direction.x])
		change_state("Fall")
	else:
		owner.velocity.y=0
	if owner.controller.processing_jump and owner.controller.allow_wall_jump:	
	#if Input.is_action_just_pressed("jump") and owner.controller.allow_wall_jump:		
		owner.controller.do_jump(-collision_direction)

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
	if t:
		t.stop()
		t=null
	owner.controller.can_climb=false
	owner.controller.climb_reload_timer.start()


# when StateAutomaticTimer timeout()
func _state_timeout() -> void:
	pass


# Called when any other Timer times out
func _on_timeout(_name) -> void:
	Logger.debug("Stop Climb because of timeout")
	change_state("Fall")
