extends Node

## Footstep Audio Manager
##
## A comprehensive audio system for handling footstep sounds across different surface materials.
## Uses an optimized audio pool system to prevent audio stuttering and improve performance.
##
## Features:
## - Multiple surface materials (grass, stone, water)
## - Walking and running sound variations
## - Audio pooling for performance optimization
## - Pitch randomization for natural sound variation
## - Spatial audio support with position parameter
##
## Usage:
## ```gdscript
## # Simple usage
## FootstepManager.play_footstep_sound("grass", true, player_position)
## 
## # Advanced usage with custom pitch
## FootstepManager.play_footstep("stone", SoundType.WALK, player_position, 1.2)
## ```

## Sound type enumeration for different movement states
enum SoundType {
	WALK, ## Walking footstep sounds
	RUN    ## Running footstep sounds
}
## Dictionary containing all preloaded footstep sounds organized by surface material and sound type
const FOOTSTEP_SOUNDS: Dictionary = {"grass": {
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
}, "dirt": {
	SoundType.WALK: [
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_01.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_02.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_03.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_04.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_05.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_06.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_07.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_08.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_09.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Walk/Footsteps_DirtyGround_Walk_10.wav"),
	],
	SoundType.RUN: [
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_01.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_02.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_03.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_04.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_05.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_06.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_07.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_08.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_09.wav"),
	preload("res://assets/sounds/footsteps/dirt/Footsteps_Dirt_Run/Footsteps_DirtyGround_Run_10.wav"),
	],
}}
## Pool of AudioStreamPlayer2D nodes for efficient audio playback
var _audio_players: Array[AudioStreamPlayer2D] = []
## Current index for round-robin audio player selection
var _current_player_index: int = 0
## Size of the audio player pool - adjust based on your needs
const AUDIO_POOL_SIZE: int = 4
## Default volume for footstep sounds (in decibels)
const DEFAULT_VOLUME_DB: float = -5.0
## Default pitch variation range for natural sound variation
const DEFAULT_PITCH_RANGE: Vector2 = Vector2(0.9, 1.1)


## Initialize the audio player pool
func _ready() -> void:
	_initialize_audio_pool()


## Creates and configures the pool of AudioStreamPlayer2D nodes
func _initialize_audio_pool() -> void:
	_audio_players.resize(AUDIO_POOL_SIZE)
	for i in AUDIO_POOL_SIZE:
		var player = AudioStreamPlayer2D.new()
		player.volume_db = DEFAULT_VOLUME_DB
		add_child(player)
		_audio_players[i] = player


## Validates if a surface material exists in the sound dictionary
## @param surface_material: The surface material to check
## @return: The validated surface material (fallback to "grass" if not found)
func _validate_surface_material(surface_material: String) -> String:
	if not FOOTSTEP_SOUNDS.has(surface_material):
		push_warning("Surface material '%s' not found, using 'grass' as fallback" % surface_material)
		return "grass"
	return surface_material


## Gets the next available audio player from the pool using round-robin selection
## @return: An available AudioStreamPlayer2D from the pool
func _get_next_audio_player() -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D = _audio_players[_current_player_index]
	_current_player_index = (_current_player_index + 1) % AUDIO_POOL_SIZE
	return player


## Advanced footstep playback with full parameter control
## @param surface_material: The surface material ("grass", "stone", "water")
## @param sound_type: The type of sound (SoundType.WALK or SoundType.RUN)
## @param position: World position for spatial audio (default: Vector2.ZERO)
## @param pitch_scale: Custom pitch scaling (default: random variation)
## @param volume_db: Custom volume in decibels (default: uses player's volume)
func play_footstep(
	surface_material: String,
	sound_type: SoundType,
	position: Vector2 = Vector2.ZERO,
	pitch_scale: float = -1.0,
	volume_db: float = -1000.0  # Use -1000 as "not set" indicator
) -> void:
	# Validate surface material
	var validated_material: String = _validate_surface_material(surface_material)

	# Get sounds array for the specified material and type
	var sounds = FOOTSTEP_SOUNDS[validated_material][sound_type]
	if sounds.is_empty():
		push_warning("No sounds found for material '%s' and sound type '%s'" % [validated_material, sound_type])
		return

	# Get next available audio player
	var player: AudioStreamPlayer2D = _get_next_audio_player()

	# Configure audio stream
	player.stream = sounds[randi() % sounds.size()]
	player.global_position = position

	# Set pitch (use custom value or random variation)
	if pitch_scale > 0.0:
		player.pitch_scale = pitch_scale
	else:
		player.pitch_scale = randf_range(DEFAULT_PITCH_RANGE.x, DEFAULT_PITCH_RANGE.y)

	# Set volume if specified
	if volume_db > -999.0: # Check if custom volume was provided
		player.volume_db = volume_db

	# Play the sound
	player.play()


## Simplified API for basic footstep playback
## @param surface_material: The surface material ("grass", "stone", "water")
## @param is_running: Whether the character is running (true) or walking (false)
## @param position: World position for spatial audio
func play_footstep_sound(surface_material: String, is_running: bool, position: Vector2) -> void:
	var sound_type: int = SoundType.RUN if is_running else SoundType.WALK
	play_footstep(surface_material, sound_type, position)
