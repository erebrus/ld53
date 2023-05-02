extends Reference
class_name GameTime

signal cycle_ended
signal tick_ended

const CYCLES_PER_DAY=4
const CYCLE_DURATION=120

var day:int=1
var cycle:int=1
var time:int=1

func tick():
	Logger.debug("tick: t=%d c=%d" %[time, cycle])
	time += 1
	emit_signal("tick_ended")
	if time > CYCLE_DURATION:
		tick_cycle()
		
func tick_cycle():
	cycle += 1
	time = 1
	if cycle > CYCLES_PER_DAY:
		Globals.emit_signal("survived")
		return
	emit_signal("cycle_ended")

func is_cycle_start()->bool:
	return time == 1		
	
func is_day_start()->bool:
	return cycle == 1	
	
func ticks_from_day_start()->int:
	return CYCLE_DURATION * (cycle-1) + time
	
func compare(other:GameTime)->int:
	return ticks_from_day_start()-other.ticks_from_day_start()
	
func set_from(ret)->GameTime:

	ret.day = day
	ret.cycle = cycle
	ret.time = time
	return ret
	
