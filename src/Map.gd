extends Node2D

var game_ended:=false
onready var courier = $Courier
onready var first_level_height = $"First Level Top"
export var level_heights = [0, 220, 440, 660, 880, 1100]
var current_level = 0
var player_level = 0
var initial_height = 0

func _ready() -> void:
	Globals.connect("survived", self, "on_game_over")
	Globals.connect("game_over", self, "on_game_over")
	Globals.emit_signal("entered_floor", 0)
	initial_height = first_level_height.global_position.y
		
func _on_Timer_timeout() -> void:
	Globals.time.tick()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if not game_ended:
			Globals.emit_signal("game_over")


func on_game_over():
	game_ended=true
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($Music, "volume_db", -80, 5)

func get_level_from_player_height():
	var level = 0
	var player_height = courier.global_position.y - initial_height
	for i in level_heights.size():
		if (i < level_heights.size() - 1) and (player_height < level_heights[i+1]):
			level = i
			break
		else:
			level = i
			
	return level

func _physics_process(delta):
	player_level = get_level_from_player_height()
	if current_level != player_level:
		Globals.emit_signal("left_floor", current_level)
		Globals.emit_signal("entered_floor", player_level)
		current_level = player_level
