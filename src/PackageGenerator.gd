extends Node2D

const PackageScene:PackedScene = preload("res://src/Package.tscn")


func _ready() -> void:
	yield(get_tree(),"idle_frame")
	new_package() #TODO remove
	
func new_package():
	var obj = PackageScene.instance()
	var recipient = RNGTools.pick(get_tree().get_nodes_in_group("npc"))
	obj.init(recipient)	
	get_parent().add_child(obj)
	obj.global_position = global_position
