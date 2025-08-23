extends Node

enum SoundType { WALK, RUN }

# Structure organisée des sons
var footstep_sounds: Dictionary = {"grass":
	{
		SoundType.WALK:
			[
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_01.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_02.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_03.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_04.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_05.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_06.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_07.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_08.wav"),
			preload("res://assets/sounds/footsteps/grass/Footsteps_Grass_Walk/Footsteps_Walk_Grass_Mono_10.wav"),
			],
		SoundType.RUN:
			[
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
			],
	}, "stone":
	{
		SoundType.WALK:
			[
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_01.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_02.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_03.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_04.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Walk/Footsteps_Rock_Walk_05.wav"),
			],
		SoundType.RUN:
			[
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_01.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_02.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_03.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_04.wav"),
			preload("res://assets/sounds/footsteps/stone/Footsteps_Rock_Run/Footsteps_Rock_Run_05.wav"),
			],
	}, "water":
	{
		SoundType.WALK:
			[
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_01.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_02.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_03.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_04.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Walk/Footsteps_WaterV1_Walk_05.wav"),
			],
		SoundType.RUN:
			[
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_01.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_02.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_03.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_04.wav"),
			preload("res://assets/sounds/footsteps/water/Footsteps_Water_Run/Footsteps_Water_Run_05.wav"),
			],
	}}

# Pool d'AudioStreamPlayer2D pour éviter les conflits
var audio_players: Array[AudioStreamPlayer2D] = []
var current_player_index: int                 = 0


func _ready():
	# Crée plusieurs players pour overlapping sounds
	for i in range(4):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		audio_players.append(player)


func play_footstep(material: String, sound_type: SoundType, position: Vector2 = Vector2.ZERO, pitch_variation: float = 0.1) -> void:
	if not footstep_sounds.has(material):
		material = "grass" # fallback

	if not footstep_sounds[material].has(sound_type):
		return

	var sounds = footstep_sounds[material][sound_type]
	if sounds.is_empty():
		return

	# Utilise le prochain player disponible (round-robin)
	var player: AudioStreamPlayer2D = audio_players[current_player_index]
	current_player_index = (current_player_index + 1) % audio_players.size()

	# Configure et joue
	player.stream = sounds[randi() % sounds.size()]
	player.global_position = position
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	player.play()


# Fonction utilitaire pour les différents types de pas
func play_walk_sound(material: String, position: Vector2):
	play_footstep(material, SoundType.WALK, position)


func play_run_sound(material: String, position: Vector2):
	play_footstep(material, SoundType.RUN, position)