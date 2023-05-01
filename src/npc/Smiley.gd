extends Node2D

const Oscilation:= 2

onready var sprites:= $sprites
onready var sprite_list = [$sprites/happy, 
	$sprites/positive, 
	$sprites/neutral, 
	$sprites/sad, 
	$sprites/angry]

enum State {HAPPY, POSITIVE, NEUTRAL, SAD, ANGRY}

var state = State.NEUTRAL

func _process(delta: float) -> void:
	var ticks = OS.get_ticks_msec()/400.0
	sprites.position.y=cos(ticks)*Oscilation
	yield(get_tree().create_timer(4), "timeout")

#	on_relationship_change(.5)	

func init(val:float):
	state = get_state_for_value(val)
	update_sprite()
	modulate.a=0
	
func show():
	var tween=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self,"modulate", Color.white,.2)

func hide():
	var tween=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var color = Color.white
	color.a=0
	tween.tween_property(self,"modulate", color,.2)

func update_sprite():
	for i in range(sprite_list.size()):
		sprite_list[i].visible = State.values()[i] == state

func get_state_for_value(val:float):
	if val >.7:
		return State.HAPPY
	if val > .25 :
		return State.POSITIVE
	if val > -.25:
		return State.NEUTRAL
	if val > -.75:
		return State.SAD
	return State.ANGRY
	
func on_relationship_change(val:float):
	state = get_state_for_value(val)
	update_sprite()
	#TODO make it a smooth transition with fades
#	var new_state = get_state_for_value(val)
#	if new_state != state:
#		var old_sprite = sprite_list[state]
#		var new_sprite = sprite_list[new_state]
#		old_sprite.modulate.a = 1
#		var old_sprite_new_color=old_sprite.modulate
#		old_sprite_new_color.a= 0
#		new_sprite.modulate.a = 0
#		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
#		tween.tween_property()
