extends Node2D

const PackageScene:PackedScene = preload("res://src/Package.tscn")
const AnchorDeltaX = 16

export(Array,float) var mean_period_per_cycle=[45, 30, 20]
export var max_packages = 6
export var init_packages:int = 3
export var mean_period:float = 60
export var variability:float= .25
var last_free_anchor_count = 0
var current_free_anchor_count = 0

func _ready() -> void:
	yield(get_tree(),"idle_frame")
	for i in range(max_packages):
		var anchor = Node2D.new()
		anchor.name = "anchor%d" % (i+1)
		$anchors.add_child(anchor)
		anchor.position.x= i * AnchorDeltaX
	
	if init_packages>max_packages:
		init_packages = max_packages
	
	for i in range(init_packages):
		var anchor = get_next_free_anchor()
		if anchor:
			new_package(anchor, true)
	schedule()
	Globals.time.connect("cycle_ended", self, "on_cycle_ended")

func _process(delta):
	current_free_anchor_count = get_free_anchor_count()
	if current_free_anchor_count == last_free_anchor_count:
		return
	else:
		Globals.emit_signal("package_change", current_free_anchor_count)

func on_cycle_ended():
	if not mean_period_per_cycle.empty():
		mean_period=mean_period_per_cycle[0]
		mean_period_per_cycle.remove(0)
		Logger.info("New mean period for package generator %2f." % mean_period)

func get_next_free_anchor():
	for anchor in $anchors.get_children():
		if anchor.get_child_count()==0:
			return anchor
	return null
		
func new_package(anchor:Node2D, publish:=false):
	
	var obj = PackageScene.instance()
	var recipient = RNGTools.pick(get_tree().get_nodes_in_group("npc"))
	Logger.debug("Generated new package for %s" % recipient.get_id())
	obj.init(recipient)	
	anchor.add_child(obj)
	obj.show_puff()
	obj.position = Vector2.ZERO
	if publish:
		Globals.emit_signal("new_package", get_free_anchor_count())
	if get_free_anchor_count()<=1:
		Globals.emit_signal("last_package_anchor")
		start_reminder()	

func start_reminder():
	if $ReminderTimer.is_stopped():
		$ReminderTimer.start()


func get_free_anchor_count():
	var count=0
	for i in range($anchors.get_child_count()):
		var anchor = $anchors.get_child(i)
		if anchor.get_child_count()==0:
			count += 1
	return count
	
func schedule():
	var delta = mean_period * variability
	$Timer.wait_time = mean_period - delta + delta * 2 * randf()
	Logger.debug("Next package planned in %2f seconds" % $Timer.wait_time)
	$Timer.start()
	
func _on_Timer_timeout() -> void:
	schedule()
	var anchor = get_next_free_anchor()
	if not anchor:
		Globals.do_game_over(Globals.GameOverReason.PACKAGES)
		return
	new_package(anchor, true)


func _on_ReminderTimer_timeout() -> void:
	if get_free_anchor_count()<=1:
		Globals.emit_signal("last_package_anchor")
	else:
		$ReminderTimer.stop()
