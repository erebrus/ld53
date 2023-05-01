extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var chat = $Chat
var player_near = false
var time_since_press = 100.0
var wait_period = 2.0
export var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#sprite.play("Default")
	pass

func _process(delta: float) -> void:
	time_since_press += delta
	if !can_activate():
		return
	if Input.is_action_just_pressed("ask"):
		on_trigger()

func can_activate() -> bool:
	return player_near and time_since_press > wait_period

func on_trigger():
	$sfx_button.play()
	time_since_press = 0.0
	timer.start(6)
	MapEvents.emit_signal("call_button_pressed", level)
	
func on_elevator_arrived():
	#sprite.play("Default")
	pass

func _on_Area2D_body_entered(body):
	if !body.is_in_group("player"):
		return
	player_near = true
	anim_player.play("Outline")
	if !Globals.showed_call_tip:
		chat.open_dialog("Press Interact to Call Elevator.")
		Globals.showed_call_tip = true

func _on_Area2D_body_exited(body):
	if !body.is_in_group("player"):
		return
	player_near = false
	anim_player.play("Disappear")

func _on_Timer_timeout():
	pass
	#sprite.play("Default")
