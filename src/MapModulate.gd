extends CanvasModulate


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var first: Color
export var second: Color
export var third: Color
export var fourth: Color
export var fifth: Color
export var sixth: Color
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("entered_floor", self, "on_player_entered_floor")
	Globals.connect("left_floor", self, "on_player_left_floor")

func on_player_entered_floor(entered):
	tween.stop(self)
	tween.interpolate_property(self, "color", self.color, pick_color(entered), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
func on_player_left_floor(left):
	pass
	
func pick_color(level):
	match level:
		0:
			return first
		1:
			return second
		2: 
			return third
		3:
			return fourth
		4: 
			return fifth
		5:
			return sixth
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
