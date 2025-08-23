extends Node

enum SoundType { WALK, RUN }
const FOOTSTEP_SOUNDS: Dictionary              = {"grass": {
	SoundType.WALK: [
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_01.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_02.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_03.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_04.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_05.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_06.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_07.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_08.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_09.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_11.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_12.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_13.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_14.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_15.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_16.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_17.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_18.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_19.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_20.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_21.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_22.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_23.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_24.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_25.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_26.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_27.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_28.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_29.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_30.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_31.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_32.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_33.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_34.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_35.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_36.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_37.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_38.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_39.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_40.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_41.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_42.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_43.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_44.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_45.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_46.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_47.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_48.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_49.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_50.wav"),
	],
	SoundType.RUN: [
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_01.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_02.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_03.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_04.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_05.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_06.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_07.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_08.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_09.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_10.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_11.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_12.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_13.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_14.wav"),
	preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Run/Footsteps_Grass_Run_15.wav"),
	],
}, "stone": {
	SoundType.WALK: [
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_01.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_02.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_03.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_04.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_05.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_06.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_07.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_08.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_09.wav"),
	],
	SoundType.RUN: [
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_01.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_02.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_03.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_04.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_05.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_06.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_07.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_08.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_09.wav"),
	preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_10.wav"),
	],
}, "water": {
	SoundType.WALK: [
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV2_Walk_01.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV2_Walk_02.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV2_Walk_03.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV2_Walk_04.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV2_Walk_05.wav"),
	],
	SoundType.RUN: [
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_01.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_02.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_03.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_04.wav"),
	preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_05.wav"),
	],
}}
var _audio_players: Array[AudioStreamPlayer2D] = []
var _current_player_index: int                 = 0
const AUDIO_POOL_SIZE: int                     = 4


func _ready() -> void:
	# Pré-alloue le pool d'AudioStreamPlayer2D
	_audio_players.resize(AUDIO_POOL_SIZE)
	for i in AUDIO_POOL_SIZE:
		var player = AudioStreamPlayer2D.new()
		#		player.volume_db = -5.0  # Volume optimal
		add_child(player)
		_audio_players[i] = player


func play_footstep(surface_material: String, sound_type: SoundType, position: Vector2 = Vector2.ZERO) -> void:
	# Validation rapide - early return
	var sounds = FOOTSTEP_SOUNDS.get(surface_material, FOOTSTEP_SOUNDS.grass).get(sound_type)
	if sounds.is_empty():
		return

	# Round-robin efficace sur le pool
	var player: AudioStreamPlayer2D = _audio_players[_current_player_index]
	_current_player_index = (_current_player_index + 1) % AUDIO_POOL_SIZE

	# Configuration et lecture optimisées
	player.stream = sounds[randi() % sounds.size()]
	player.global_position = position
	player.pitch_scale = randf_range(0.9, 1.1)  # Variation subtile
	player.play()


# API simplifiée - une seule fonction publique
func play_footstep_sound(surface_material: String, is_running: bool, position: Vector2) -> void:
	play_footstep(surface_material, SoundType.RUN if is_running else SoundType.WALK, position)