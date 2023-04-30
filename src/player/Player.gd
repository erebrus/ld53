extends KinematicBody2D

const fixed_anims = ["hurt","death"]
signal health_changed
signal fired
signal jump_fired

export (bool) var disabled:bool = false

var velocity:Vector2 = Vector2.ZERO
var accel:float=0
var in_animation:bool = false
var last_y:float
var last_direction:=Vector2.RIGHT
var facing_direction:=last_direction

onready var body_sprite:AnimatedSprite = $Sprite

onready var controller = $PlatformController
onready var direction_player:AnimationPlayer = $DirAnimationPlayer
onready var timer_fs = $Sfx/FootstepTimer
onready var reload_timer = $ReloadTimer
onready var xsm := $XSM
onready var packages_container := $packages

onready var sfx_run := $Sfx/SFXRun
onready var sfx_jump := $Sfx/SFXJump
onready var sfx_landing := $Sfx/SFXLand

var can_play_footstep:bool = true

var dead:=false

var over_package = null
var target

func _ready():

	last_y=global_position.y
	last_direction=Vector2.RIGHT
	$DirAnimationPlayer.play("right")
#	setup_debug(true)
	$XSM.change_state("Idle")
	

func setup_debug(val:bool):
	if val:
		HyperLog.log(self).text("global_position>%0.2f")
		HyperLog.log(self).text("velocity>%0.2f")
		HyperLog.log(self).text("accel>%0.2f")
		HyperLog.log(self).offset(Vector2(32,-50))
	else:
		HyperLog.remove_log(self)


func update_sprite():

	
	if facing_direction != last_direction and facing_direction!=Vector2.ZERO:		
		last_direction = facing_direction
		var desired_direction = "right" if facing_direction.x > 0 else "left"
		if desired_direction != direction_player.current_animation:
			direction_player.play(desired_direction)
			


func control(_delta:float) -> void:
	if in_animation:
		return
	facing_direction = Vector2(Input.get_axis("ui_left", "ui_right"),0);
	if Input.is_action_just_pressed("jump"):
		Logger.debug("Jump was pressed. (global, should be processed by now) . States = %s" % $XSM.get_active_states())

	if Input.is_action_just_pressed("pickup"):
		pickup()
		
	if Input.is_action_just_pressed("deliver"):
		deliver()
		
	if Input.is_action_just_pressed("trip"):
		xsm.change_state("Trip")
	
	if Input.is_action_just_pressed("slip"):
		xsm.change_state("Slip")	
		
	if Input.is_action_just_pressed("wobble"):
		xsm.change_state("Wobble")	

func on_dash() -> void:
	pass

	
func on_walk_stop() -> void:
#	sfx_run.stop()
	pass
	
func on_walk() -> void:
	if not sfx_run.playing and can_play_footstep:
		sfx_run.play()
		if timer_fs.wait_time>0:
			can_play_footstep = false
			timer_fs.start()


func on_jump() -> void:
	sfx_jump.play()

	# create a rising cloud effect where the player jumps
#	var cloud = vfx_jump.instance() 
#	cloud.position = position
#	get_parent().add_child(cloud)


func on_landing(_last_vy:float):
	sfx_landing.play()


func _process(delta: float) -> void:
	
	control(delta)

	if not in_animation: # we need the check in case we got into animation in control
		update_sprite()

	

func _on_FootstepTimer_timeout():
	can_play_footstep=true


func on_attacked(dmg):
	
	Logger.info("player was attacked")
#	if not check_for_death():
#		$XSM.change_state("Hurt")
#	emit_signal("health_changed")

	
#func check_for_death():
#	Logger.info("checking death: lives %d" % lives)
#	if lives==0:
#		set_collision_enabled(false)
#		dead=true
#		$XSM.change_state("Death")
#		return true
#	return false


func set_collision_enabled(val):
	disabled = !false
	$CollisionShape2D.disabled= !val
	if val:
		collision_layer=4
	else:
		collision_layer=0





func stop_animation():
	$Sprite.playing=false

func start_animation():
	$Sprite.playing=true


func set_platform_collision_enabled(val):
	if val:
		collision_layer=4
		collision_mask=3	
	else:
		collision_layer=0
		collision_mask=0	


func trip():
	xsm.change_state("Trip")

func pickup():
	if not over_package and packages_container.get_child_count() == 0:
		return
	
	if over_package:			
		over_package.being_carried=true
		over_package.get_parent().remove_child(over_package)		
		packages_container.add_child(over_package)				
		over_package.global_position = packages_container.global_position	 \
			+ Vector2(0, -8)*(packages_container.get_child_count()-1)	
		over_package=null
	else:
		var package = packages_container.get_child(0)
		var prev_pos = package.global_position
		package.get_parent().remove_child(package)
		get_parent().add_child(package)
		package.global_position = prev_pos
		package.being_carried=false
		over_package=package
		reset_package_position()
		
func reset_package_position():
	for i in range(packages_container.get_child_count()):
			var p = packages_container.get_child(i)
			p.global_position = packages_container.global_position	 \
			+ Vector2(0, -8)*i	
func deliver():
	if not target or packages_container.get_child_count() == 0:
		return
	var package = packages_container.get_child(0)
	if target.process_package(package):
		package.consume()
		reset_package_position()
		
