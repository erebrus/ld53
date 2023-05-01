extends Reference
class_name GameTime

signal cycle_ended

const CYCLES_PER_DAY=4
const CYCLE_DURATION=120

var day:int=1
var cycle:int=1
var time:int=1

func tick():
	time += 1
	if time > CYCLE_DURATION:
		tick_cycle()
		
func tick_cycle():
	cycle += 1
	time = 1
	if cycle > CYCLES_PER_DAY:
		cycle = 1
		day +=1
		emit_signal("cycle_ended")

func is_cycle_start()->bool:
	return time == 1		
	
func is_day_start()->bool:
	return cycle == 1	
	
