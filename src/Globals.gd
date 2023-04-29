extends Node

signal reply_package(package, source, reply)
signal bark(source, message)




enum GameLogLevel {INFO, WARNING, ALERT}

var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false

var music:AudioStreamPlayer

var lives

func _ready():
	_init_logger()	
	connect("bark", self, "log_bark")
	connect("reply_package", self, "log_reply")
#	music =AudioStreamPlayer.new()	
#	music.stream=preload("res://assets/music/CatEgypt.mp3")
#	music.volume_db=-20
#	add_child(music)

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
	Logger.set_logger_level(Logger.LOG_LEVEL_TRACE)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_TRACE




