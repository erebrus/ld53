extends Node2D



export(float) var dash_cooldown:float = 1.0
export(float) var max_speed:float = 300
export(float) var max_accel:float = 60
export(float) var max_deccel:float = 50
export(float) var dash_boost:float = 600
export(float) var dash_hangtime:float = .5

export(float) var th:float = .6 # time of jump, from start to landing
export(float) var h:float = 450 # max height of jump
export(float) var v_limit:float =900 #max vertical speed
export(float) var delta_factor:float = 2
export(float) var damping_speed:float = 300 # +y speed added if jump button released before jump is over.

export(int) var max_air_jumps = 0 # allows for double jump (and triple jump, etc)
export(float) var inertia_factor:float = .1
export(float) var air_accel_factor:float = .2 # factor applied to acceleration while on air
export(float) var coyote_time:float = 0.2 # time after leaving a platform that the player can still jump
export(float) var jump_buffer:float = 0.2 # time before landing that a jump command will stil take place after landing
export(float) var hangtime:float = 0.1 # time before gravity starts being applied when player reaches zenith of jump
export(float) var climb_timeout:float = 1 # time before gravity starts being applied when player reaches zenith of jump
export(bool) var allow_wall_jump:bool = false
export(bool) var wall_jump_x:float=300
export(float) var wall_control_timeout:float=.3
export(float) var g_factor:float = 1

export(NodePath) var xsm_path:NodePath

var hanging := false #is in hangtime
var jump_available := true #can jump
var can_dash:bool = true 
var can_climb:bool = false  

var air_jump_count:int = 0
var jump_requested:bool = false #for jump buffer
var accept_coyote_jump:bool = false #for coyote time
var landed=false #has landed
var discard_jump:=false

#var accel:float=0 # current accel
#var velocity:Vector2 = Vector2.ZERO
onready var dash_timer:Timer = $DashTimer
onready var xsm:State = get_node(xsm_path)
onready var climb_reload_timer:Timer = $ClimbReloadTimer

onready var g:float = 2 * h / (th * th) # computed gravity
onready var v0:float = 2 * h / th # computed initial velocity

var player
var processing_jump:bool = false

func _ready():
	player = get_parent()
	validate_parent()
	
	Logger.debug("Player v0=%f g=%f" % [v0, g])
	dash_timer.wait_time=dash_cooldown
	

func _is_can_climb()->bool:	
	return bool(climb_timeout)
	
func _get_actual_g()->float:
#	if player.velocity.y<.1:
#		return g*g_factor
#	else:
		return g*g_factor

#ensures parent is compatible with controller
func validate_parent():
	assert("last_y" in player)
	assert("last_direction" in player)
	assert("in_animation" in player)
	assert("velocity" in player)
	assert("accel" in player)

	assert(player.has_method("on_landing"))
	assert(player.has_method("update_sprite"))
#	assert(player.has_method("get_max_dash_distance"))	
	assert(player is KinematicBody2D)


func temporarily_disable_air_control(time:float=wall_control_timeout):
	var tmp_air_accel = air_accel_factor
	air_accel_factor=0
	yield(get_tree().create_timer(time), "timeout")	
	air_accel_factor=tmp_air_accel
	
func do_wall_impulse(wall_normal:Vector2):
	Logger.trace("wall jump")
	player.velocity.x=wall_normal.x*wall_jump_x
	temporarily_disable_air_control()


func do_jump(wall_normal=null):
	Logger.debug("trying jump")
	if jump_available:	
		Logger.debug("Jumping")
		xsm.change_state("Jump")
#		sfx_jump.play()
		player.velocity.y=-v0
		if wall_normal:
			do_wall_impulse(wall_normal)
			
		jump_available = false
		landed=false
		discard_jump=false
		if !player.is_on_floor() and not is_in_coyote_time():
			air_jump_count += 1		
		player.on_jump()

	elif !player.is_on_floor() and player.velocity.y>0:
		jump_requested=true
		Logger.debug("jump rejected because it was not available")
		get_tree().create_timer(jump_buffer).connect("timeout",self,"reset_jump_buffer")

	processing_jump=false



func control(_delta:float) -> void:
#	if Globals.get_world().paused:
#		return
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
			

	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("ui_down"):
			do_platform_drop()
		else:
			Logger.debug("Controller handling jump")
			if jump_available:
				processing_jump=true
			else:
				Logger.debug("jump discarded. not available.")
	if Input.is_action_just_released("jump"):
		jump_available=true

	
func do_platform_drop():
	#disabled
	pass
#	player.set_platform_collision_enabled(false)
#	yield(get_tree().create_timer(.25), "timeout")
#	player.set_platform_collision_enabled(true)
	
func do_dash()->void:
	Logger.trace("dash")
	can_dash=false
	player.velocity.x=dash_boost*player.last_direction.x
	player.on_dash()
	dash_timer.start()

func is_in_coyote_time()	:
	return accept_coyote_jump

func reset_coyote_time():
	accept_coyote_jump=false
		
func reset_jump_buffer():
	jump_requested=false

func reset_hangtime():
	hanging = false

func _on_DashTimer_timeout():
	can_dash = true


func _process(delta: float) -> void:
	if player.disabled:
		return
	#if we are in animation, gravity still works
	if player.in_animation:
		player.velocity.y += _get_actual_g() * delta * delta_factor
		if abs(player.velocity.x):
			if (abs(player.velocity.x)>5):
				player.velocity.x=0
			else:
				player.velocity.x -=5*sign(player.velocity.x)
		player.velocity=player.move_and_slide(player.velocity, Vector2.UP)
		Logger.trace("in animation movement")
		return

	control(delta)
	
	if abs(player.velocity.x) > max_speed: #friction
		var f = 1 if owner.is_on_floor() else owner.controller.inertia_factor
		var tmp_max=min(abs(owner.controller.max_deccel*f),abs(owner.velocity.x-max_speed))
		owner.accel = -tmp_max if owner.velocity.x>0 else tmp_max
		player.velocity.x += owner.accel
		Logger.trace("reduce excess speed")

	#player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)		
	player.velocity.y = clamp(player.velocity.y, -v0*10, v_limit)
	

	var was_on_floor = player.is_on_floor()
	var y = player.global_position.y
	var last_vy=player.velocity.y
	
	Logger.trace("applying velocity %s" % player.velocity)
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	Logger.trace("POST applying velocity %s" % player.velocity)
	
	if player.is_on_floor():
		landed = true

	if was_on_floor and not player.is_on_floor():
		player.last_y = y	

	#Apply gravity if not on floor and not hanging
	if !player.is_on_floor() and not hanging:
		var was_going_up = player.velocity.y <=0
		player.velocity.y += _get_actual_g() * delta * delta_factor
	elif player.is_on_floor():
		air_jump_count = 0
	
	if not player.in_animation: # we need the check in case we got into animation in control
		player.update_sprite()



func _on_ClimbTimer_timeout():
	can_climb = true
