extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim_player=  $AnimationPlayer
onready var timer = $Timer
onready var tip_timer = $TooltipTimer
onready var stop = $Stop
onready var elevator_sign = $Sign
onready var sfx_arrives = $sfx_arrives
onready var sfx_leaves = $sfx_leaves
onready var chat = $Chat
export var level_y_height = 224.0
export var wait_door_close = 2.0
var is_player_inside = false
var total_levels = 6
var current_level = 0
var target_level = 0
var y_delta = 0
var moving = false
var direction = -1
var levels = []
var velocity = 0
var speed = 100
var slow_down_speed = 40
var slowest_speed = 10
var time_since_request = 0
var target_pos = 0
var called_slowing_elevator = false

# Called when the node enters the scene tree for the first time.
func _ready():
	MapEvents.connect("up_button_pressed", self, "go_up")
	MapEvents.connect("down_button_pressed", self, "go_down")
	MapEvents.connect("call_button_pressed", self, "go_to_call")
	for i in total_levels:
		levels.append(position.y + i * level_y_height)

func go_up(level: int) -> void:
	if current_level == 0:
		return
	
	direction = -1
	target_level = 0
	if moving:
		stop()
	begin_moving()
	
func go_down(level: int) -> void:
	if current_level == total_levels - 1:
		return
	direction = 1
	target_level = total_levels - 1
	if moving:
		stop()
	begin_moving()
	
func go_to_call(level: int) -> void:
	if level == current_level:
		return
	if level < current_level:
		direction = -1
	else:
		direction = 1
	target_level = level
	if moving:
		stop()
	begin_moving()
	
	
func begin_moving():
	if target_level != current_level:
		sfx_leaves.play()
		if is_player_inside:
			Globals.emit_signal("player_in_moving_elevator")
		time_since_request = 0
		moving = true
		called_slowing_elevator = false
		y_delta = levels[target_level] - position.y


func request_stop():
	if moving == false:
		return
	stop.play("On")
	var closest_distance = 1000.0
	var distance = 0.0
	# Find closest level to stop at
	for i in total_levels:
		distance = levels[i] - position.y
		if distance == 0:
			target_level = i
		elif distance/abs(distance) == direction and abs(distance) < closest_distance:
			target_level = i
			closest_distance = abs(distance)
	
		

func stop():
	sfx_arrives.play()
	stop.play("Off")
	moving = false
	called_slowing_elevator = false
	if is_player_inside:
		Globals.emit_signal("player_in_stopped_elevator")
	
	# no doors..
	open_door()
	timer.start(wait_door_close)

# NO DOORS - sorry
func open_door():
	#anim_player.play("open_door")
	pass

# NO DOORS - sorry
func close_door():
	#anim_player.play("close_door")
	pass

func _physics_process(delta: float):
	
	if is_player_inside and Input.is_action_just_pressed("ask"):
		request_stop()
	
	var distance = 0
	time_since_request += delta
	if moving:
		distance = abs(levels[target_level] - position.y)
		
		if distance < 20:
			velocity = lerp(speed, slowest_speed, 1 - (distance / 20))
		if distance < 40:
			velocity = lerp(speed, slow_down_speed, 1 - (distance / 40))
			if is_player_inside and !called_slowing_elevator:
				Globals.emit_signal("player_in_slowing_elevator")	
				called_slowing_elevator
		else:
			called_slowing_elevator = true
			velocity = lerp(0, speed, time_since_request / 4)
		
		target_pos = position.y + direction * velocity * delta
		if abs(target_pos - levels[target_level]) < 1.0:
			current_level = target_level
			position.y = levels[target_level]
			stop()
		else:
			position.y = target_pos
		
		for i in total_levels:
			distance = abs(levels[i] - position.y)
			if distance < 100:
				elevator_sign.change_sign(i)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Timer_timeout():
	close_door()


func _on_Area2D_body_entered(body):
	if !body.is_in_group("player"):
		return
	is_player_inside = true
	$AnimationPlayer.play("Enter")

func _on_Area2D_body_exited(body):
	if !body.is_in_group("player"):
		return
	is_player_inside = false
	$AnimationPlayer.play("Leave")
	
func show_tooltip():
	if !Globals.showed_elevator_button_tip:
		chat.open_dialog("Move up or down using your controls.")
		Globals.showed_elevator_button_tip = true
	tip_timer.start(2)

func _on_TooltipTimer_timeout():
	
	if !Globals.showed_stop_button_tip:
		Globals.showed_stop_button_tip = true
		chat.open_dialog("Press the interact button\n to stop.")
