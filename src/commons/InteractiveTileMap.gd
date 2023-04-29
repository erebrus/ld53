extends TileMap
class_name InteractiveTilemap

export(bool) var debug_mode := false

export(Dictionary) var TILE_SCENES:Dictionary= {}

onready var half_cell_size := cell_size * 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_replace_tiles_with_scenes()

func _replace_tiles_with_scenes(scene_dictionary:Dictionary = TILE_SCENES):
	for tile_pos in get_used_cells():
		var tile_id = get_cell(tile_pos.x, tile_pos.y)
		
		if scene_dictionary.has(tile_id):
			var obj_scene = scene_dictionary[tile_id]
			_replace_tile_with_object(tile_id, tile_pos, obj_scene)
	
func _replace_tile_with_object(tile_id:int, tile_pos:Vector2, object_scene:PackedScene, parent: Node = self):
	#clear cel in tilemap

		
	if get_cellv(tile_pos) != INVALID_CELL and not debug_mode:
		set_cellv(tile_pos, -1)
		update_bitmask_region()
		
	#spawn the object
	if object_scene:
		var obj = object_scene.instance()
#		var offset=obj.get_tilemap_offset()
		var offset=Vector2(8,8)
		if obj.has_method("get_tilemap_offset"):
			offset = obj.get_tilemap_offset()
		if obj.has_method("init_tileset_id"):
			obj.init_tileset_id(tile_id)
		var obj_pos = map_to_world(tile_pos) + offset
		parent.add_child(obj)
		obj.global_position = to_global(obj_pos)
		if is_cell_transposed(tile_pos.x, tile_pos.y):
			obj.rotation = PI/2
		if is_cell_x_flipped(tile_pos.x, tile_pos.y):
			obj.rotation = PI/2
		if is_cell_y_flipped(tile_pos.x, tile_pos.y):
			obj.rotation = PI/2
		if debug_mode:
			schedule_blink(obj)


func schedule_blink(obj):
	obj.visible = not obj.visible
	yield(get_tree().create_timer(1),"timeout")		
	schedule_blink(obj)
