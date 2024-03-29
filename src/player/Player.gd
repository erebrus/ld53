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
#onready var reload_timer = $ReloadTimer
onready var xsm := $XSM
onready var packages_container := $packages
onready var sprite :=$Sprite
onready var sfx_run := $Sfx/SFXRun
onready var sfx_jump := $Sfx/SFXJump
onready var sfx_landing := $Sfx/SFXLand
onready var sfx_wobble := $Sfx/SFXWobble
onready var sfx_drop_package := $Sfx/SFXDrop
onready var sfx_pickup_package := $Sfx/SFXPickUp
onready var sfx_slip := $Sfx/SFXSlip
onready var sfx_trip := $Sfx/SFXTrip
onready var wheel: = $BoxWheelUI

var can_play_footstep:bool = true

var dead:=false

var over_package = null
var target
var money:int = 0

var instability:float=0

func _ready():
	Globals.connect("go_down_floor", self, "go_down_floor")
	Globals.connect("go_up_floor", self, "go_up_floor")
	Globals.connect("reply_package", self, "on_packaged_delivered")
	last_y=global_position.y
	last_direction=Vector2.RIGHT
	$DirAnimationPlayer.play("right")
#	setup_debug(true)
	$XSM.change_state("Idle")
	Globals.connect("last_package_anchor", self, "on_last_package_anchor")
	Globals.connect("reply_package", self, "on_packaged_delivered")
	Globals.connect("survived", self, "on_game_over")
	Globals.connect("game_over", self, "on_game_over")

func on_game_over():
	in_animation=true
	set_process(false)
	set_physics_process(false)
	
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
		if Input.is_action_just_released("deliver"):
			deliver()
		elif Input.is_action_just_released("ask"):
			ask()
		elif !Input.is_action_pressed("ask") and !Input.is_action_pressed("deliver"):
			hide_wheel()
		return
	facing_direction = Vector2(Input.get_axis("ui_left", "ui_right"),0);
	if Input.is_action_just_pressed("jump"):
		Logger.debug("Jump was pressed. (global, should be processed by now) . States = %s" % $XSM.get_active_states())

	if Input.is_action_just_pressed("pickup") and can_pickup():
		pickup()
		
	elif Input.is_action_just_pressed("deliver") and !Input.is_action_pressed("ask"):
		show_wheel()
	elif Input.is_action_just_released("deliver"):
		deliver()
	
	if Input.is_action_just_pressed("ask") and !Input.is_action_pressed("deliver"):
		show_wheel()
	elif Input.is_action_just_released("ask"):
		ask()
	if !Input.is_action_pressed("ask") and !Input.is_action_pressed("deliver"):
		hide_wheel()
			
	if Input.is_action_just_pressed("trip"):
		xsm.change_state("Trip")
	
	if Input.is_action_just_pressed("slip"):
		slip()
		
	if Input.is_action_just_pressed("wobble"):
		xsm.change_state("Wobble")	


func slip():
	xsm.change_state("Slip")	
	
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
	if global_position.y > 5000:
		Globals.emit_signal("game_over")
	control(delta)
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		instability+=.05*get_package_count()
	if Input.is_action_just_pressed("jump"):
		instability+=.2*get_package_count()
		
	if not in_animation: # we need the check in case we got into animation in control
		update_sprite()

	

func _on_FootstepTimer_timeout():
	can_play_footstep=true


func on_attacked(dmg):
	
	Logger.info("player was attacked")
#	if not check_for_death():
#		$XSM.change_state("Hurt")
#	emit_signal("health_changed")

func go_down_floor(current, target):
	pass

func go_up_floor(current, target):
	pass
	

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
	hide_wheel()

func get_package_count()->int:
	var count = 0
	for package_anchor in packages_container.get_children():
		if package_anchor.get_child_count()>0:
			count += 1
	return count
	
func push_package(package):
	wheel.hide_wheel()
	if get_package_count() == packages_container.get_child_count():
		Logger.debug("Cannot pick up more packages")
		return
	packages_container.get_child(get_package_count()).add_child(package)
	package.position = Vector2.ZERO
	
func pop_package():
	wheel.hide_wheel()
	if get_package_count() == 0:
		return null
	var ret = packages_container.get_child(0).get_child(0)
	ret.get_parent().remove_child(ret)
	for i in range(1, packages_container.get_child_count()):
		if packages_container.get_child(i).get_child_count()>0:
			var p = packages_container.get_child(i).get_child(0)
			p.get_parent().remove_child(p)
			packages_container.get_child(i-1).add_child(p)
			p.position=Vector2.ZERO				
	return ret

func pop_selected_package(package):
	var ret = null
	if get_package_count() == 0:
		return ret
		
	# first remove the selected package from the array
	for package_anchor in packages_container.get_children(): 
		if package_anchor.get_child(0) == package:
			ret = package_anchor.get_child(0)
			ret.get_parent().remove_child(ret)
			break
	
	# now shift array backwards to fill empty slots
	if ret != null:
		for i in range(0, packages_container.get_child_count()):
			# try to fill anchor if empty by searching forward in array
			if packages_container.get_child(i).get_child_count() == 0:
				for z in range (i+1, packages_container.get_child_count()):
					if packages_container.get_child(z).get_child_count() > 0:
						var p = packages_container.get_child(z).get_child(0)
						p.get_parent().remove_child(p)
						packages_container.get_child(i).add_child(p)
						p.position=Vector2.ZERO		
					
	return ret
	
func can_pickup()->bool:
	return over_package and get_package_count() < 3

func pickup():
	if not can_pickup():
		return
	
	if over_package:			
		over_package.being_carried=true
		over_package.get_parent().remove_child(over_package)		
		push_package(over_package)	
		over_package=null
		sfx_pickup_package.play()
#	else:
#		WE NO LONGER DROP PACKAGES
		
#
#		var package = pop_package()
#		if not package:
#			Logger.warn("Tried to pop package, but found no package.")
#			return
#		var prev_pos = packages_container.get_child(0).global_position		
#		get_parent().add_child(package)
#		package.global_position = prev_pos
#		package.being_carried=false
#		sfx_drop_package.play()
#		over_package=package
		
func ask():
	if not target or get_package_count() == 0:
		return
	
	wheel.hide_wheel()
	var package = get_package(wheel.get_selection())
	target.ask_about(package.target_name, package.target_section)

func show_wheel():
	in_animation=true
	wheel.show_wheel(get_packages())
	
func hide_wheel():
	wheel.hide_wheel()
	in_animation=false

func deliver():
	if not target or packages_container.get_child_count() == 0:
		return
	var package = get_package(wheel.get_selection())
	if package == null:
		return
	if target.process_package(package):
		var glob = package.global_position
		pop_selected_package(package)
		Globals.emit_signal("package_received")
		remove_child(package)
		get_parent().add_child(package)
		package.global_position = glob
		package.consume(target)

func adjust_package_x():
	for i in range(get_package_count()):
		var package = packages_container.get_child(i).get_child(0)
		if facing_direction.x < 0:
			package.position.x = -package.position.x

func get_package(idx:int):
	if idx<0 or idx >2 or packages_container.get_child(idx).get_child_count() == 0:
		return null
	return packages_container.get_child(idx).get_child(0)

func get_packages():
	var package_list = []
	for i in 3:
		package_list.append(get_package(i))
		
	return package_list

func on_trip():
	if get_package_count() == 0:
		return
	
	
	var velocities = [ 
		(Vector2(-7,12)-Vector2(-4,4))*10 * -last_direction * Vector2(2,1),
		(Vector2(-16,1)-Vector2(-7,-6))*10 * -last_direction * Vector2(2,1),
		(Vector2(-24,-10)-Vector2(-13,-14))*10 *-last_direction * Vector2(2,1),
	]	
	var packages_dropped = []
	for i in range(get_package_count()):
		var package = packages_container.get_child(i).get_child(0)
		package.velocity = velocities[i]
		var pos = package.global_position
		package.get_parent().remove_child(package)
		get_parent().add_child(package)
		package.global_position = pos
		packages_dropped.append(package)
		package.being_carried = false
		

func on_slip():
	if get_package_count() == 0:
		return
		
#	var positions := [
#			[Vector2(0,0), Vector2(-4,4), Vector2(-7,12)],
#			[Vector2(0,8), Vector2(-7,-6), Vector2(-16,1)],
#			[Vector2(0,16), Vector2(-13,-14),Vector2(-24,-10)]
#		]
#	for plist in positions:
#		for i in range(plist.size()):
#			plist[i]=plist[i]*facing_direction
#
#	var velocities = [ 
#		(positions[0][2]-positions[0][1])*10 ,
#		(positions[1][2]-positions[1][1])*10 ,
#		(positions[2][2]-positions[2][1])*10 ,				
#
#	]
#	for i in range(get_package_count()):	
#		packages_container.get_child(i).position = positions[i][0]
#
#	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)	
#	tween.tween_property(packages_container.get_child(0), "position", positions[0][1],.1 )
#	for i in range(1, get_package_count()):
#		tween.parallel().tween_property(packages_container.get_child(i), "position", positions[i][1],.1 )
#	yield(tween,"finished")			
#	tween.tween_property(packages_container.get_child(0), "position", positions[0][2],.1 )
#	for i in range(1, get_package_count()):
#		tween.parallel().tween_property(packages_container.get_child(i), "position", positions[i][2],.1 )
#	yield(tween,"finished")			
	var velocities = [ 
		(Vector2(-7,12)-Vector2(-4,4))*10 *last_direction,
		(Vector2(-16,1)-Vector2(-7,-6))*10 *last_direction,
		(Vector2(-24,-10)-Vector2(-13,-14))*10 *last_direction
	]	
	var packages_dropped = []
	for i in range(get_package_count()):
		var package = packages_container.get_child(i).get_child(0)
		package.velocity = velocities[i]
		var pos = package.global_position
		package.get_parent().remove_child(package)
		get_parent().add_child(package)
		package.global_position = pos
		packages_dropped.append(package)
		package.being_carried = false
		

func on_last_package_anchor():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc.global_position.distance_to(self.global_position) < 300:
			npc.warn_player()
			
			
func on_packaged_delivered(package, source, reply):
	var current_money = money
	var gain = Package.INCOME_BY_TIMELINESS[reply]
	money = clamp(money+Package.INCOME_BY_TIMELINESS[reply],-100,10000)
	Globals.emit_signal("gain_money", current_money, gain)
	if money == -100:
		#Globals.do_game_over(Globals.GameOverReason.MONEY)
		Globals.emit_signal("game_over")
	Logger.info("Player money %d" % money)
#	match reply:
#		Package.Timeliness.QUICK:
#
#		Package.Timeliness.JUST_IN_TIME:
#			pass
#		Package.Timeliness.DELAYED:
#			pass
#		Package.Timeliness.VERY_DELAYED:
#			pass
	
func _on_StabilityTimer_timeout():
	
	if is_on_floor() and randf()<instability:
		xsm.change_state("Wobble")

func _on_RecoveryTimer_timeout():
	instability = clamp(instability-.01,0,.9)
