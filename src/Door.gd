extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var timer = $Timer
onready var anim_player = $AnimationPlayer
onready var chat = $Chat
onready var area2D = $Area2D
var player_near = false
export var level = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("Default")

func _process(delta: float) -> void:
	if !can_activate():
		return
	if Input.is_action_just_pressed("ui_up") and level != 1:
		on_trigger_up()
	elif Input.is_action_just_pressed("ui_down") and level < 6:
		on_trigger_down()

func _physics_process(delta):
	var bodies = area2D.get_overlapping_bodies()
	player_near = false
	for body in bodies:
		if body.is_in_group("player"):
			player_near = true
			break

func can_activate() -> bool:
	return player_near

func on_trigger_up():
	Globals.emit_signal("go_up_floor", level, level - 1)

func on_trigger_down():
	Globals.emit_signal("go_down_floor", level, level + 1)
	
func open_door():
	$SFXOpen.play()
	timer.start(1)
	sprite.play("Open")
	Globals.emit_signal("door_opened")
	
func close_door():
	$SFXClose.play()
	sprite.play("Close")
	Globals.emit_signal("door_closed")
	timer.stop()
	
func _on_Area2D_body_entered(body):
	if !body.is_in_group("player"):
		return
	anim_player.play("Outline")
	if !Globals.showed_door_tip:
		chat.open_dialog("Press Up or Down.")
		Globals.showed_door_tip = true

func _on_Area2D_body_exited(body):
	if !body.is_in_group("player"):
		return
	anim_player.play("Disappear")

func _on_Timer_timeout():
	close_door()
	
