extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim_player=  $AnimationPlayer
onready var timer = $Timer
export var level_y_height = 224.0
export var wait_door_close = 2.0
var current_level = 0
var target_level = 0
var y_delta = 0
var moving = false
var direction = -1
var levels = []
var velocity = 0
var speed = 40
var time_since_request = 0
var target_pos = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	MapEvents.connect("up_button_pressed", self, "go_up")
	MapEvents.connect("down_button_pressed", self, "go_down")
	for i in 6:
		levels.append(position.y + i * level_y_height)

func go_up(level: int) -> void:
	direction = -1
	target_level = level
	if current_level == target_level:
		target_level = 0
	if moving:
		stop()
	begin_moving()
	
func go_down(level: int) -> void:
	print("DOWN!")
	direction = 1
	target_level = level
	if current_level == target_level:
		target_level = 5
	if moving:
		stop()
	begin_moving()
	
func begin_moving():
	if target_level != current_level:
		print(target_level)
		time_since_request = 0
		moving = true
		y_delta = levels[target_level] - position.y

func stop():
	moving = false
	open_door()
	timer.start(wait_door_close)
	
func open_door():
	#anim_player.play("open_door")
	pass

func close_door():
	#anim_player.play("close_door")
	pass

func _integrate_forces(state):
	print("MOVING!")
	
	
func _physics_process(delta: float):
	time_since_request += delta
	if moving:
		print("MOVING!")
		
		var distance = abs(levels[target_level] - position.y)
		if distance < 100:
			velocity = lerp(speed, 5, 1 - (distance / 100))
		else:
			velocity = lerp(0, speed, time_since_request / 4)
		
		target_pos = position.y + direction * velocity * delta
		if abs(target_pos - levels[target_level]) < 1.0:
			current_level = target_level
			position.y = levels[target_level]
			stop()
		else:
			position.y = target_pos
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	close_door()
