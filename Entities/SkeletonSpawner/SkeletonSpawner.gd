extends Node2D

var tilemap
var tree_tilemap

export var spawn_area : Rect2 = Rect2(50, 150, 700, 700)
export var max_skeletons = 100
export var start_skeletons = 10
var skeleton_count = 0
var skeleton_scene = preload("res://Entities/Skeleton/Skeleton.tscn")

var rnd = RandomNumberGenerator.new()

func _ready():	
	tilemap = get_tree().root.get_node("Root/TileMap")
	tree_tilemap = get_tree().root.get_node("Root/TreeTileMap")
	
	rnd.randomize()
	
	for i in range(start_skeletons):
		instance_skeleton()
	skeleton_count = start_skeletons

func test_position(position : Vector2):
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
		
	cell_coord = tree_tilemap.world_to_map(position)
	cell_type_id = tree_tilemap.get_cellv(cell_coord)
	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	
	return grass_or_sand and no_trees

func instance_skeleton():
	var skeleton = skeleton_scene.instance()
	add_child(skeleton)
	skeleton.connect("death", self, "_on_Skeleton_death")
	
	var valid_position = false
	while not valid_position:
		skeleton.position.x = spawn_area.position.x + rnd.randf_range(0, spawn_area.size.x)
		skeleton.position.y = spawn_area.position.y + rnd.randf_range(0, spawn_area.size.y)
		valid_position = test_position(skeleton.position)
	
	skeleton.arise()


func _on_Timer_timeout() -> void:
	if skeleton_count < max_skeletons:
		instance_skeleton()
		skeleton_count = skeleton_count + 1
		
func _on_Skeleton_death():
	skeleton_count = skeleton_count - 1
