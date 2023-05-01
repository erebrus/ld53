extends KinematicBody2D

const BananaScene:PackedScene = preload("res://src/world/Banana.tscn")
const CANDY_MODIFIER :=.2
const TIMELINESS_MODIFIERS:Dictionary = {
	Package.Timeliness.QUICK: .2,
	Package.Timeliness.JUST_IN_TIME: .05,
	Package.Timeliness.DELAYED: -.2,
	Package.Timeliness.VERY_DELAYED: -.5
}
const WRONG_DEPARTMENT_MODIFIER=-.1
const WRONG_PERSON_MODIFIER=-.1
const ASK_MODIFIER=-.05

enum Timeliness {QUICK, JUST_IN_TIME, DELAYED, VERY_DELAYED}


export var max_speed=24



var call_name:String
var call_section:String
var relationship:float=0 setget _set_relationship

var last_direction= Vector2.RIGHT
var velocity:Vector2 = Vector2.ZERO
var target_position 

#onready var sprite := $Sprite
onready var tree := $AnimationTree
onready var dialog := $Chat
onready var leg := $Leg
onready var sfx_talk := $sfx/sfx_talk
onready var sfx_bark :=  $sfx/sfx_trumpet
onready var sfx_laugh := $sfx/sfx_laugh
onready var sfx_wow := $sfx/sfx_wow
onready var smiley := $Smiley

var active_sfx

var props := {}
var is_female := false

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var seek = rng.randf_range(0, 2)
	tree.set("parameters/Idle/Seek/seek_position", seek)
	Globals.connect("player_slipped", self, "on_player_slipped")

	smiley.init(relationship)
	
func get_id()->String:
	return "%s (%s)" % [call_name, call_section]

#func _physics_process(delta: float) -> void:	
#	velocity=Vector2.ZERO
#	if target_position:
#		velocity = Vector2.RIGHT * max_speed * sign(target_position.x - global_position.x)
#
#	if not is_on_floor():
#		velocity.y += 1000 * delta
#	velocity=move_and_slide(velocity, Vector2.UP)
#
#	_update_sprite()

#func _update_sprite():
#	if sign(last_direction.x) != sign(velocity.x):
#		last_direction=Vector2(sign(velocity.x),0).normalized()
#		sprite.flip_h= last_direction.x < 0


	
func on_player_slipped(pos):
	if global_position.distance_to(pos) < 200:
		show_dialog(Globals.get_random_line(Globals.BarkType.BARK_SLIP))
		
func process_package(package):
	if package.target_name == call_name and \
		package.target_section == call_section:
			var timeliness = package.get_timeliness(Globals.time)
			Logger.debug("%s - received package. Timeliness = %d" % [get_id(), timeliness] )
			update_relationship(TIMELINESS_MODIFIERS[timeliness])
			Logger.debug("%s - new relationship state: %f" % [get_id(), relationship])
			Globals.emit_signal("reply_package", package, self, timeliness)
			if timeliness>1:
				show_dialog(get_timeliness_dialog(timeliness), sfx_bark)
			elif timeliness==1:
				show_dialog(get_timeliness_dialog(timeliness), sfx_talk)
			else:
				show_dialog(get_timeliness_dialog(timeliness), sfx_wow)
			return true	
	else:
		Logger.debug("%s - received wrong package" % get_id())
		Globals.emit_signal("bark", self, get_wrong_recipient_message())
		show_dialog(get_wrong_recipient_message(), sfx_talk)
		update_relationship(WRONG_PERSON_MODIFIER)
		return false


func get_wrong_recipient_message():
	#TODO make this a random message
	return "This package is not for me!"
	
func get_timeliness_dialog(timeliness):
	match timeliness:
		Package.Timeliness.DELAYED:
			return get_dialog(Globals.BarkType.DELAYED)
		Package.Timeliness.JUST_IN_TIME:
			return get_dialog(Globals.BarkType.JUST_IN_TIME)
		Package.Timeliness.QUICK:
			return get_dialog(Globals.BarkType.QUICK)
		Package.Timeliness.VERY_DELAYED:
			return get_dialog(Globals.BarkType.VERY_DELAYED)

func get_dialog(category):
	var bark_list = Globals.barks[category]
	var index = RNGTools.randi_range(0, len(bark_list))
	return bark_list[index]

func update_relationship(delta):
	relationship = clamp(relationship + delta, -1,1)
	smiley.on_relationship_change(relationship)
	
func give_candy():
	update_relationship(CANDY_MODIFIER)
	#TODO random message
	Globals.emit_signal("bark", self, "Thank you for the candy...I guess")
	show_dialog("Thank you for the candy...I guess", sfx_talk)

func set_body(res):
	$AntPivot/Body.texture = load(res)
	Logger.debug("%s - set body res: %s" % [get_id(), res])

func set_glasses(res):
	if res:
		$AntPivot/HeadPivot/Glasses.texture = load(res)
		Logger.debug("%s - set glasses res: %s" % [get_id(), res])
	else:
		$AntPivot/HeadPivot/Glasses.texture = null

func set_facial(res):
	if res:
		$AntPivot/HeadPivot/FacialHair.texture = load(res)
		Logger.debug("%s - set facial hair res: %s" % [get_id(), res])
	else:
		$AntPivot/HeadPivot/FacialHair.texture = null

func set_hair(res):
	if res:
		$AntPivot/HeadPivot/Hair.texture = load(res)
		Logger.debug("%s - set hair res: %s" % [get_id(), res])
	else:
		$AntPivot/HeadPivot/Hair.texture = null

func set_head(res):
	$AntPivot/HeadPivot/Head.texture = load(res)
	Logger.debug("%s - set hair res: %s" % [get_id(), res])

func set_tie(res):
	if res:
		$AntPivot/Tie.texture = load(res)
		Logger.debug("%s - set tie res: %s" % [get_id(), res])
	else:
		$AntPivot/Tie.texture = null	
		
func show_dialog(text: String, sfx=null) -> void:
	dialog.open_dialog(text)
	if sfx:
		sfx.play()
		yield(get_tree().create_timer(text.length()*.05+.2),"timeout")
		sfx.stop()

func on_dialog_done(sfx):
	if active_sfx:
		active_sfx.stop()	
	dialog.disconnect("done",self,"on_dialog_done")
	
func _on_DetectionBox_body_entered(body):
	Logger.debug("%s - detected played." % get_id())
	smiley.show()
	body.target = self
	if relationship > -.1:
		return
	if relationship > -.9:
		if randf()< abs(relationship)/2:			
			Globals.emit_signal("bark", self, Globals.get_random_line(Globals.BarkType.BARK))
	else:
		if randf() > .5:
			do_trip()			
		else:
			Globals.emit_signal("bark", self, Globals.get_random_line(Globals.BarkType.BARK))
	
func do_trip():
	$Leg/AnimationPlayer.play("extend")

func _on_DetectionBox_body_exited(body):
	if body.target == self:
		body.target = null
		Logger.trace("%s - no longer detects played." % get_id())
	smiley.hide()


	
func add_prop(key, value):
	props[key]=value


func get_colleagues():
	var npcs = get_tree().get_nodes_in_group("npc")
	var ret = []
	for npc in npcs:
		if npc.call_section == call_section:
			ret.append(npc)
	return ret
	
func ask_about(target_name, target_section):
	if target_section != call_section:
		show_dialog(Globals.get_random_line(Globals.BarkType.ASK_WRONG_DEPARTMENT),sfx_talk)
#		Globals.emit_signal("bark", self, )
		update_relationship(WRONG_DEPARTMENT_MODIFIER)
		return

	if call_name == target_name and call_section == target_section:
		show_dialog("It's me you idiot!",sfx_wow)
		update_relationship(WRONG_PERSON_MODIFIER)
		return
		
	var target = null
	for npc in get_colleagues():
		if npc.call_name == target_name:
			target = npc
			break
	
	if target == null:
		#Globals.emit_signal("bark", self, "I have no clue who that is.")
		show_dialog("I have no clue who that is.", sfx_talk)
		update_relationship(WRONG_PERSON_MODIFIER)
		yield(get_tree().create_timer(1),"timeout")
		sfx_talk.stop()
	else:
#		Globals.emit_signal("bark", self, build_directions_reply(target))
		show_dialog(build_directions_reply(target),sfx_talk)
		update_relationship(ASK_MODIFIER)

		
func build_directions_reply(target):
	var keys = target.props.keys()
	var props_count = 2 #+ 1 if randf()>.4 else 0
	if props_count > keys.size():
		props_count = keys.size()
	if props_count == 0:
		return "I have no clue who that is."
	
	var target_props = RNGTools.pick_many(target.props.keys(), 2)
	var body=""
	for prop in target_props:
		if prop == "body_type":
			body=" %s" % Globals.get_text_for_prop(prop, target.props[prop])
	
	for prop in target_props:
		if prop == "colour":
			body="%s %s" % [body, Globals.get_text_for_prop(prop, target.props[prop])]
	
	var other=""
	for prop in target_props:
		if prop !=	"colour" and prop != "body_type":
			var txt= Globals.get_text_for_prop(prop, target.props[prop])
			if other == "":
				other = "the %s" % txt
			else:
				other = "%s and the %s" % [other, txt]
	var ant 
	if body != "":
		ant = "That's the %s ant" % body
	else:
		ant = "That's the ant"
	
	if other!= "":
		ant = "%s with %s." % [ant,other]
	else:
		ant= "%s." % ant
	
	var prop = RNGTools.pick(target.props.keys())
	var comment = adjust_gender(Globals.get_comment_for_prop(prop, target.props[prop]), target.is_female)
	ant = "%s %s" % [ant, comment]
	return ant


func adjust_gender(comment:String, is_female:bool)->String:
	if is_female:
		var ret = comment.replacen("_His_", "Her")\
			.replacen("_his_", "her")\
			.replacen("_him_", "her")\
			.replacen("_he_", "she")\
			.replacen("_He_", "She")
		return ret
	else:			
		return comment.replacen("_","")
		


func _on_Leg_body_entered(body: Node) -> void:
	body.trip()
	$Leg/AnimationPlayer.play("retreat")
	show_dialog(Globals.get_random_line(Globals.BarkType.BARK_TRIP), sfx_bark)


func _on_PrankTimer_timeout() -> void:
	if relationship < -.8 and randf() < .25:
		var banana = BananaScene.instance()
		$PrankAnchor.add_child(banana)
		banana.position = Vector2.ZERO
		Logger.debug("generated banana at %s" % str(banana.global_position))	
	schedule_prank_check()
	
func schedule_prank_check():
	$PrankTimer.wait_time(RNGTools.randi_range(20, 120))
	
func _set_relationship(val):
	relationship=val
	smiley.on_relationship_change(val)

func warn_player():
	show_dialog(Globals.get_random_line(Globals.BarkType.ALMOST_LOSING), sfx_bark)
