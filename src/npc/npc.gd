extends KinematicBody2D
class_name Npc

const CANDY_MODIFIER :=.2
const TIMELINESS_MODIFIERS:Dictionary = {
	Package.Timeliness.QUICK: .2,
	Package.Timeliness.JUST_IN_TIME: .05,
	Package.Timeliness.DELAYED: -.2,
	Package.Timeliness.VERY_DELAYED: -.5
}

const BARKS:Array = [
	"Why does everything always take so long around here?",
"I'm sorry, I can't hear you over the sound of my deadlines whooshing by.",
"I swear, they just hire anyone these days.",
"I don't have time for this. Can't you see I'm busy?",
"Why do I even bother coming in to work anymore?",
"You call that work? I could do it in my sleep.",
"I can't believe they expect us to work in these conditions.",
"I'm so sick of these incompetent couriers messing everything up.",
"Just once, I'd like to get something done without any delays or excuses.",
"Why do they even bother with deadlines? No one ever meets them anyway."
]

export var max_speed=24



var call_name:String
var call_section:String
var relationship:float=0

var last_direction= Vector2.RIGHT
var velocity:Vector2 = Vector2.ZERO
var target_position 

onready var sprite := $Sprite
onready var tree := $AnimationTree

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var seek = rng.randf_range(0, 2)
	tree.set("parameters/Idle/Seek/seek_position", seek)
	
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
		
	

func process_package(package):
	if package.target_name == call_name and \
		package.target_section == call_section:
			Logger.debug("%s - received wrong package" % get_id())
			Globals.emit_signal("bark", self, get_wrong_recipient_message())
	else:
		var timeliness = package.get_timeliness(Globals.get_time())
		Logger.debug("%s - received package. Timeliness = %d" % [get_id(), timeliness] )
		update_relationship(TIMELINESS_MODIFIERS[timeliness])
		Logger.debug("%s - new relationship state: %f" % [get_id(), relationship])
		Globals.emit_signal("reply_package", package, self, timeliness)
		package.consume()

func get_wrong_recipient_message():
	#TODO make this a random message
	return "This package is not for me!"

func update_relationship(delta):
	relationship = clamp(relationship + delta, -1,1)


func _on_DetectionArea_body_entered(body: Node) -> void:
	if relationship > -.1:
		return
	if relationship > -.9:
		if randf()< abs(relationship)/2:			
			Globals.emit_signal("bark", self, RNGTools.pick(BARKS))
	else:
		if randf() > .5:
			body.trip()
		else:
			Globals.emit_signal("bark", self, RNGTools.pick(BARKS))


func give_candy():
	update_relationship(CANDY_MODIFIER)
	#TODO random message
	Globals.emit_signal("bark", self, "Thank you for the candy...I guess")

func ask_about(target_name, target_address):
	Logger.error("%s - asked about %s (%s)" % [get_id(), target_name, target_address])

func set_body(res):
	Logger.debug("%s - set body res: %s" % [get_id(), res])


func set_glasses(res):
	Logger.debug("%s - set glasses res: %s" % [get_id(), res])


func set_facial(res):
	Logger.debug("%s - set facial hair res: %s" % [get_id(), res])


func set_hair(res):
	Logger.debug("%s - set hair res: %s" % [get_id(), res])
