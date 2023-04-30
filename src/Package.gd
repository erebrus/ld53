extends Node2D
class_name Package

enum Timeliness {QUICK, JUST_IN_TIME, DELAYED, VERY_DELAYED}

var start_day:int
var start_cycle:int 


var target_name:String
var target_section:String

var being_carried:=false

func init(recipient):
	target_name = recipient.call_name
	target_section = recipient.call_section
	start_day = Globals.time.day
	start_cycle = Globals.time.cycle
	

func get_timeliness(time:GameTime):
	if time.day > start_day:
		return Timeliness.VERY_DELAYED
	if time.cycle > start_cycle:
		if time.cycle > start_cycle+1 or time.time > Globals.CYCLE_DURATION/2:
			return Timeliness.VERY_DELAYED
		else:
			return Timeliness.DELAYED
	elif time.time > Globals.CYCLE_DURATION/2:
		return Timeliness.JUST_IN_TIME
	else:
		return Timeliness.QUICK
		
func consume():
	get_parent().remove_child(self)
	queue_free()
	
	


func _on_Package_body_entered(body: Node) -> void:
	if being_carried:
		return
	if body.is_in_group("player"):
		body.over_package=self


func _on_Package_body_exited(body: Node) -> void:
	if being_carried:
		return
	if body.is_in_group("player") and body.over_package==self:
		body.over_package=null
