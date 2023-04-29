extends Node2D
class_name Package

enum Timeliness {QUICK, JUST_IN_TIME, DELAYED, VERY_DELAYED}

var start_day:int
var start_cycle:int 


var target_name:String
var target_section:String

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
	
	
