extends Panel

signal sfx_changed(value)
signal music_changed(value)
signal master_changed(value)

signal panel_closed()


onready var master_slider = $MarginContainer/VBoxContainer/GridContainer/MasterSlider/HSlider
onready var sfx_slider = $MarginContainer/VBoxContainer/GridContainer/MusicSlider/HSlider
onready var music_slider = $MarginContainer/VBoxContainer/GridContainer/SfxSlider/HSlider


var unlock_done:=false
func _ready():
	yield(get_tree(), "idle_frame")
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -5)
	print(str(AudioServer.get_bus_volume_db(db2linear(AudioServer.get_bus_index("Master")))))
	print(str(master_slider.value))
	master_slider.value = AudioServer.get_bus_volume_db(db2linear(AudioServer.get_bus_index("Master")))
	print(str(master_slider.value))
	print("t")
#	music_slider.value = AudioServer.get_bus_volume_db(db2linear(AudioServer.get_bus_index("music")))
#	sfx_slider.value = AudioServer.get_bus_volume_db(db2linear(AudioServer.get_bus_index("sfx")))


func _on_Close_pressed():
	emit_signal("panel_closed")
	visible=false


func _on_sfx_value_changed(value):
	emit_signal("sfx_changed", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db(value))
	Logger.info("sound volume = %2f" % AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")) )


func _on_music_value_changed(value):
	emit_signal("music_changed", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db(value))
	Logger.info("music volume = %2f (%2f)" % [value, AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music"))] )


func _on_master_value_changed(value):
	emit_signal("master_changed", value)
	Logger.info("master volume changed to %2f" % value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	
