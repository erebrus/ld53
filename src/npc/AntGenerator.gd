extends Node2D

const AntScene:PackedScene = preload("res://src/npc/Npc.tscn")

enum BodyType {THIN, NORMAL, FAT}
enum BellyColour {BLUE, GREY, BROWN, YELLOW, RED}
enum Tie {NONE, BLACK, RED}
enum Hair {SHORT_BLACK, SHORT_BROWN, SHORT_BLOND, LONG_BLACK, LONG_RED, LONG_BLOND}
enum Glasses {NONE, BLACK, RED, SUN}
enum FacialHair {NONE, BLACK, BROWN, BLOND}
var body_preffix = "res://assets/gfx/npcs/anim_resources/body"
var body_suffix = ".tres"


func _ready() -> void:
	var ant = AntScene.instance()

	ant.call_name = pick_name()
	ant.call_section = get_parent().name
	ant.set_body(get_body())
	ant.set_glasses(get_glasses_res_name(RNGTools.pick(Glasses.values())))
	ant.set_facial(get_facial_res_name(RNGTools.pick(FacialHair.values())))
	ant.set_hair(get_hair_res_name(RNGTools.pick(Hair.values())))

	
	yield(get_tree(),"idle_frame")	
	get_parent().add_child(ant)
	ant.global_position = global_position
	yield(get_tree(),"idle_frame")	
	queue_free()
	
func get_body():
	var type = RNGTools.pick(BodyType.values())
	var colour = RNGTools.pick(BellyColour.values())
	var tie = RNGTools.pick(Tie.values())	
	return get_body_res_name(type, colour, tie)
	

func get_hair_res_name(type):
	var str_type = Hair.keys()[type].to_lower()
	return "res://assets/gfx/npcs/anim_resources/hair_%s.tres" % str_type


func get_facial_res_name(type):
	var str_type = FacialHair.keys()[type].to_lower()
	return "res://assets/gfx/npcs/anim_resources/facial_%s.tres" % str_type
		
func get_glasses_res_name(type):
	var str_type = Glasses.keys()[type].to_lower()
	return "res://assets/gfx/npcs/anim_resources/glasses_%s.tres" % str_type 

func get_body_res_name(type, colour, tie):
	var str_type = BodyType.keys()[type].to_lower()
	var str_colour = BellyColour.keys()[colour].to_lower()
	var str_tie = Tie.keys()[tie].to_lower()
	return "res://assets/gfx/npcs/anim_resources/body_%s_%s_%s.tres" % [str_type, str_colour, str_tie] 

func pick_name()->String:
	var name = RNGTools.pick(Globals.game_names)
	Globals.game_names.erase(name)
	return name
	
