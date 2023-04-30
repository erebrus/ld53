extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var timer = $Timer
var player_near = false
var time_since_press = 100.0
var wait_period = 2.0
export var level = 0

signal up_button_pressed(requested_level)
signal down_button_pressed(requested_level)

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
	time_since_press = 0.0
	timer.start(6)
	sprite.play("Up")
	MapEvents.emit_signal("up_button_pressed", level)

func on_trigger_down():
	time_since_press = 0.0
	timer.start(6)
	sprite.play("Down")
	MapEvents.emit_signal("down_button_pressed", level)
	
func on_elevator_arrived():
	sprite.play("Default")


func _on_Area2D_body_entered(body):
	print("HERE")
	print(body)
	player_near = true


func _on_Area2D_body_exited(body):
	print("exiting")
	print(level)
	player_near = false


func _on_Timer_timeout():
	sprite.play("Default")