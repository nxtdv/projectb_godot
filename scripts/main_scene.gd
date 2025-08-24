extends Node2D

func _ready() -> void:
	MusicManager.set_volume(0.3)
	MusicManager.play_music("gameplay/overworld", 2.0)
