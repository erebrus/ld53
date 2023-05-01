extends KinematicBody2D
class_name Package

enum Timeliness {QUICK, JUST_IN_TIME, DELAYED, VERY_DELAYED}
const INCOME_BY_TIMELINESS = [15,5,0,-10]
onready var tween = $Tween
onready var anim_player = $AnimationPlayer

var start_day:int
var start_cycle:int 


var target_name:String
var target_section:String

var being_carried:=false setget _set_being_carried
var velocity:Vector2 =Vector2.ZERO

onready var puff:AnimatedSprite = $Puff

func init(recipient):
	target_name = recipient.call_name
	target_section = recipient.call_section
	start_day = Globals.time.day
	start_cycle = Globals.time.cycle
	
func show_puff():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(puff, "modulate", Color.white, .1)
	puff.play("default")
	yield(get_tree().create_timer(.8),"timeout")
	puff.modulate.a=0

func _set_being_carried(val:bool):
	$CollisionShape2D.disabled = val
	being_carried=val
	
func get_timeliness(time:GameTime):
	if time.day > start_day:
		return Timeliness.VERY_DELAYED
	if time.cycle > start_cycle:
		if time.cycle > start_cycle+1 or time.time > GameTime.CYCLE_DURATION/2:
			return Timeliness.VERY_DELAYED
		else:
			return Timeliness.DELAYED
	elif time.time > GameTime.CYCLE_DURATION/2:
		return Timeliness.JUST_IN_TIME
	else:
		return Timeliness.QUICK
		
func consume(target):
	print("target position")
	print(target.position)
	move_to(target.position)
	anim_player.play("Consume")
	
func _physics_process(delta: float) -> void:
	if not being_carried:
		if not is_on_floor():
			velocity.y += 1000 * delta
		else:
			velocity.x=0
		velocity=move_and_slide(velocity, Vector2.UP)

func move_to(pos):
	print(self.get_global_position())
	print(pos)
	tween.stop(self)
	tween.interpolate_property(self, "global_position", self.global_position, pos, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func _on_Package_body_entered(body: Node) -> void:
	if being_carried:
		return
	if body.is_in_group("player"):
		body.over_package=self
		Logger.debug("Player hovering over package for %s (%s)" % [target_name, target_section])


func _on_Package_body_exited(body: Node) -> void:
	if being_carried:
		return
	if body.is_in_group("player") and body.over_package==self:
		body.over_package=null

func on_consume_complete():
	queue_free()
