extends CanvasLayer

export(Color) var fade_color:Color=Color.white
export(float) var fade_duration:float=.5
var transparent:Color


onready var color_rect:ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	transparent=Color(fade_color.r, fade_color.g, fade_color.b, 0)
	color_rect.color=transparent


func change_scene_to(target:PackedScene) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(color_rect, "color", fade_color,fade_duration)
	yield(tween,"finished")
	get_tree().change_scene_to(target)
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(color_rect, "color", transparent,fade_duration)
	
	
func change_scene(target:String) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(color_rect, "color", fade_color,fade_duration)
	yield(tween,"finished")
	get_tree().change_scene(target)
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(color_rect, "color", transparent,fade_duration)
