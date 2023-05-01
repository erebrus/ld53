extends Node

signal reply_package(package, source, reply)
signal bark(source, message)

signal trip()
signal player_in_moving_elevator()
signal player_in_slowing_elevator()
signal player_in_stopped_elevator()
signal package_received()
signal door_opened()
signal door_closed()
signal go_down_floor(current, target)
signal go_up_floor(current, target)

#move to map
var time=GameTime.new()



var first_names:Array
var last_names:Array
var game_names:Array=[]

enum BarkType {QUICK, JUST_IN_TIME, DELAYED, VERY_DELAYED, BARK, BARK_TRIP, BARK_SLIP}
var BarkFiles = [
	"res://data/reply_quick.txt",
	"res://data/reply_in_time.txt",
	"res://data/reply_late.txt",
	"res://data/reply_very_late.txt",
	"res://data/barks.txt",
	"res://data/bark_trip.txt",
	"res://data/bark_slip.txt"	
	
]
var barks:Dictionary = {}

enum GameLogLevel {INFO, WARNING, ALERT}

var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false
var showed_elevator_button_tip = false
var showed_stop_button_tip = false
var showed_door_tip = false

var music:AudioStreamPlayer

func _ready():
	randomize()
	_init_logger()	
	connect("bark", self, "log_bark")
	connect("reply_package", self, "log_reply")
	
	read_names()
	generate_game_names(30)
	read_barks()
#	music =AudioStreamPlayer.new()	
#	music.stream=preload("res://assets/music/CatEgypt.mp3")
#	music.volume_db=-20
#	add_child(music)

func read_barks():
	var idx=0
	for bark_file in BarkFiles:
		barks[idx] = get_list_from_file(bark_file)
		idx += 1
	Logger.info("Barks read.")


func read_names():
	first_names = get_list_from_file("res://data/first_names.txt")
	last_names = get_list_from_file("res://data/last_names.txt")


func get_list_from_file(filename):
	var ret = []
	var f = File.new()
	f.open(filename, File.READ)

	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line().strip_edges()
		if line != "":
			ret.append(line)
	f.close()
	return ret
	
func log_reply(package, source, message):
	Logger.info("%s about reply: %s" % [source.get_id(), message])	
		
func log_bark(source, message):
	Logger.info("%s barked: %s" % [source.get_id(), message])	
	
func start_music():
	if music:
		music.play()

func stop_music():
	if music:
		music.stop()
		
func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_NONE)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_NONE
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_NONE



func generate_with_reps(names:Array, count, max_repeat):
	var ret=[]
	while len(ret) < count:
		var rep:int = RNGTools.randi_range(1,max_repeat+1)
		var name:String = names[RNGTools.randi_range(0,len(names))]
		if len(ret) + rep > count:
			rep = count - len(ret)
		for i in range(rep):
			ret.append(name)
	return ret
	
func generate_game_names(count, max_repeat=3):

	var chosen_first_names = generate_with_reps(first_names,count, max_repeat)
	var chosen_last_names = generate_with_reps(last_names,count, max_repeat)

	var names = []
	for i in range(count):
		var done = false
		var first_idx = -1
		var last_idx = -1
		while not done:
			first_idx = RNGTools.randi_range(0, len(chosen_first_names))
			last_idx = RNGTools.randi_range(0, len(chosen_last_names))
			var name = "%s %s" % [first_names[first_idx], last_names[last_idx]]
			if not name in names:
				done=true
				names.append(name)
				print ("%d %s" %[i,name])
#		chosen_first_names.remove(first_idx)
#		chosen_last_names.remove(last_idx)
	game_names = names
