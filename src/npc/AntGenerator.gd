extends Node2D

const AntScene:PackedScene = preload("res://src/npc/npc2.tscn")
const FEMALE_NAME_IDX=21

var ant_sprite_name_map = {
	BodyType.THIN: "ant_1",
	BodyType.NORMAL: "ant_4",
	BodyType.FAT: "ant_2",
	BodyType.OLD: "ant_3",
}
enum BodyType {THIN, NORMAL, FAT, OLD}
enum BellyColour {GREEN, GREY, ORANGE, BLUE}
enum Tie {NONE, BLUE, YELLOW}
enum Hair {NONE, PINK_LONG, BLUE_LONG, BLUE_BUNS, BLUE_SHORT, BLONDE_SHORT, GREEN_SHORT}
enum Glasses {NONE, BLUE, GREEN, SUN_GREEN, SUN_YELLOW}
enum FacialHair {NONE, YELLOW, BLUE, GREEN}



func _ready() -> void:

	var ant = AntScene.instance()

	ant.call_name = pick_name()
	var is_female = check_if_female(ant.call_name)
	ant.call_section = get_parent().name
	var body_type = RNGTools.pick(BodyType.values())
	var colour = RNGTools.pick(BellyColour.values())
	var head = get_head_res(body_type)

	var tie = "" if is_female else get_tie_res(RNGTools.pick(Tie.values()))
	var glasses = get_glasses_res(RNGTools.pick(Glasses.values()))
	var facial = "" if is_female else get_facial_res(RNGTools.pick(FacialHair.values()))
	var hair = get_hair_res(RNGTools.pick( [1,2,3,4] if is_female else Hair.values()))

	ant.set_body(get_body_res(body_type, colour))
	ant.set_head(head)
	ant.set_tie(tie)
	ant.set_glasses(glasses)
	ant.set_facial(facial)
	ant.set_hair(hair)


	yield(get_tree(),"idle_frame")	
	get_parent().add_child(ant)
	ant.global_position = global_position
	yield(get_tree(),"idle_frame")	
	queue_free()
	

func get_head_res(type):
	var str_type = ant_sprite_name_map[type]
	return "res://assets/gfx/npcs/ants/%s_head_orange.png" % str_type #color doesn't matter
	
func get_hair_res(type):
	if type == 0:
		return null
	var str_type = Hair.keys()[type].to_lower()
	return "res://assets/gfx/npcs/hair/hair_%s.png" % str_type

func get_tie_res(type):
	if type == 0:
		return null
	var str_type = Tie.keys()[type].to_lower()
	return "res://assets/gfx/npcs/tie/tie_%s.png" % str_type

func get_facial_res(type):
	if type == 0:
		return null
	var str_type = FacialHair.keys()[type].to_lower()
	return "res://assets/gfx/npcs/facial/facial_%s.png" % str_type
		
func get_glasses_res(type):
	if type == 0:
		return null
	var str_type = Glasses.keys()[type].to_lower()
	return "res://assets/gfx/npcs/glasses/glasses_%s.png" % str_type 

func get_body_res(type, colour):
	var str_type = ant_sprite_name_map[type]
	var str_colour = BellyColour.keys()[colour].to_lower()
	return "res://assets/gfx/npcs/ants/%s_body_%s.png" % [str_type, str_colour] 

func pick_name()->String:
	var name = RNGTools.pick(Globals.game_names)
	Globals.game_names.erase(name)
	return name

func check_if_female(name):
	var idx=0
	for fname in Globals.first_names:
		if name.begins_with(fname):
			if idx <= FEMALE_NAME_IDX:
				return true
			else:
				return false
		idx += 1
	assert(false) #TODO remove
			
	
