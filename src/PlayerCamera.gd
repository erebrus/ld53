extends Camera2D

# all credit to The Shaggy Dev and his youtube video: https://www.youtube.com/watch?v=RVtcnkuNUIk&t=60s
export var random_shake_strength: float = 30.0
export var shake_decay_rate: float = 5.0
export var noise_shake_speed: float = 30.0
export var shake_starting_intensity: float = 60.0

onready var rng = RandomNumberGenerator.new()
onready var noise = OpenSimplexNoise.new()
var shake_intensity:float = 0.0
var noise_i: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("trip", self, "shake")
	Globals.connect("player_in_moving_elevator", self, "shake")
	Globals.connect("player_in_slowing_elevator", self, "shake")
	Globals.connect("player_in_stopped_elevator", self, "shake")
	Globals.connect("package_received", self, "shake")
	Globals.connect("door_opened", self, "shake")
	
	rng.randomize()
	noise.seed = rng.randi()
	noise.period = 2

func shake():
	shake_intensity = shake_starting_intensity
	

func _process(delta):
	shake_intensity = lerp(shake_intensity, 0, shake_decay_rate * delta)
	offset = get_noise_offset(delta)
	
func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * noise_shake_speed
	return Vector2(noise.get_noise_2d(1, noise_i) * shake_intensity, noise.get_noise_2d(100, noise_i) * shake_intensity)


func _on_Player_health_changed():
	shake()
