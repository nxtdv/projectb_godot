extends Node2D

@onready var terrain_layer: TileMapLayer = $World/TilemapLayers/TileMapLayer
@onready var farming_layer: TileMapLayer = $World/TilemapLayers/FarmingLayer


func _ready() -> void:
	var provider = OverworldMaterialProvider.new(terrain_layer, farming_layer)
	MaterialManager.set_material_provider(provider)

	MusicManager.set_volume(0.25)
	MusicManager.play_music("gameplay/overworld", 2.0)
