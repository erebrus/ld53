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
	if owner.is_on_floor():
		change_state("Idle")
	else:
		change_state("Fall")


# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	
	if not owner.is_on_floor():		
		owner.sfx_fire_jump.play()
		owner.emit_signal("jump_fired")
	else:
		owner.sfx_fire.play()
		owner.velocity.x=0
		owner.emit_signal("fired")	
	owner.set_attack_box_enabled(true)
	owner.can_attack = false
	owner.reload_timer.start()	
	owner.do_recoil()
	yield(get_tree().create_timer(.2),"timeout")
	owner.set_attack_box_enabled(false)


# This function is called just after the state enters
# XSM after_enters the children first, then the parent
func _after_enter(_args) -> void:
	pass


# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if not owner.is_on_floor():
		if abs(input.x)<.1 && abs(owner.velocity.x)>.1:			
			var f = 1 if owner.is_on_floor() else owner.controller.inertia_factor
			var tmp_max=min(abs(owner.controller.max_deccel*f),abs(owner.velocity.x))
			owner.accel = -tmp_max if owner.velocity.x>0 else tmp_max
			Logger.trace("do inertia")
		else:	
			#player isn't moving
			if abs(owner.velocity.x) < 0.1:
				var f = 1 if owner.is_on_floor() else owner.controller.air_accel_factor 
				#input in same direction of speed FIXME?
				if (input.x >.1 and owner.velocity.x>=0) or (input.x <.1 and owner.velocity.x<=0):
					owner.accel = +owner.controller.max_accel*f*input.x				
					Logger.trace("do input in same direction of speed")
				else: 
					Logger.trace("do input NOT in same direction of speed")
					var tmp_max=min(abs(owner.controller.max_deccel*f),abs(owner.velocity.x))
					owner.accel = -tmp_max if owner.velocity.x>0 else tmp_max				
			else: #player is moving
				var f = 1 if owner.is_on_floor() else owner.controller.air_accel_factor 
				owner.accel = +owner.controller.max_accel*f*input.x				
				Logger.trace("player moving apply accel")

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


