extends Area2D

signal sound_played(subtitles)

export (AudioStream) var sound:AudioStream
export (bool) var one_time:bool = true
export (float) var min_interval:float = 5
export(String, MULTILINE) var text: String

var can_play:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if sound:
		$sfx.stream = sound
	$Timer.wait_time=min_interval



func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and can_play:
		if sound:
			emit_signal("sound_played", text)
			$sfx.play()
			can_play=false
			if not one_time:				
				$Timer.start()



func _on_Timer_timeout():
	can_play=true

