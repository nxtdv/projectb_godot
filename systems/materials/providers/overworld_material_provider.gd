class_name OverworldMaterialProvider
extends IMaterialProvider

var terrain_layer: TileMapLayer
var farming_layer: TileMapLayer
var _last_position: Vector2i = Vector2i.MAX
var _cached_material: String = "grass"


func _init(terrain: TileMapLayer, farming: TileMapLayer = null):
	terrain_layer = terrain
	farming_layer = farming


func get_material_at(world_pos: Vector2) -> String:
	if not terrain_layer:
		return "grass"

	var tile_pos: Vector2i = terrain_layer.local_to_map(terrain_layer.to_local(world_pos))

	# Cache simple
	if tile_pos == _last_position:
		return _cached_material

	_last_position = tile_pos

	# 2. Farming (terre labourée) 
	if farming_layer:
		var farming_tile_id: int = farming_layer.get_cell_source_id(tile_pos)
		if farming_tile_id != -1:
			_cached_material = "dirt"
			return _cached_material

	# 3. Terrain de base
	var tile_data: TileData = terrain_layer.get_cell_tile_data(tile_pos)
	if tile_data and tile_data.get_custom_data("material"):
		_cached_material = str(tile_data.get_custom_data("material"))
		return _cached_material

	_cached_material = "grass"
	return _cached_material