extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var chat = $Chat
export var inside_elevator = false
var player_near = false
var time_since_press = 100.0
var wait_period = 2.0
export var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("Default")

func _process(delta: float) -> void:
	time_since_press += delta
	if !can_activate():
		return
	if Input.is_action_just_pressed("ui_up"):
		on_trigger_up()
	elif Input.is_action_just_pressed("ui_down"):
		on_trigger_down()


func can_activate() -> bool:
	return player_near and time_since_press > wait_period

func on_trigger_up():
	$sfx_button.play()
	time_since_press = 0.0
	timer.start(6)
	sprite.play("Up")
	MapEvents.emit_signal("up_button_pressed", level)

func on_trigger_down():
	$sfx_button.play()
	time_since_press = 0.0
	timer.start(6)
	sprite.play("Down")
	MapEvents.emit_signal("down_button_pressed", level)
	
func on_elevator_arrived():
	sprite.play("Default")


func _on_Area2D_body_entered(body):
	if !body.is_in_group("player"):
		return
	player_near = true
	anim_player.play("Outline")
#	if !Globals.showed_elevator_button_tip:
#		chat.open_dialog("Press Up or Down.")
#		Globals.showed_elevator_button_tip = true

func _on_Area2D_body_exited(body):
	if !body.is_in_group("player"):
		return
	print("exiting")
	print(level)
	player_near = false
	anim_player.play("Disappear")

func _on_Timer_timeout():
	sprite.play("Default")
