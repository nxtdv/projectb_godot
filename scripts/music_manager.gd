extends Node

## Music Manager
##
## A comprehensive music system for handling background music with smooth transitions.
## Supports different music tracks for various game states (menu, gameplay, combat, etc.)
##
## Features:
## - Smooth crossfading between tracks
## - Volume control with fade in/out
## - Music state management (play, pause, stop)
## - Multiple music categories support
## - Looping control
## - Save/restore music state
##
## Usage:
## ```gdscript
## # Simple usage
## MusicManager.play_music("gameplay_theme")
## MusicManager.set_volume(0.7)
## 
## # Advanced usage with crossfade
## MusicManager.crossfade_to_music("combat_theme", 2.0)
## ```

## Music tracks organized by category and name
const MUSIC_TRACKS: Dictionary = {"menu": {
	"main_menu": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"settings": preload("res://assets/music/gameplay/Pixel 10.ogg"),
}, "gameplay": {
	"overworld": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"exploration": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"peaceful": preload("res://assets/music/gameplay/Pixel 10.ogg"),
}, "combat": {
	"boss_battle": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"normal_battle": preload("res://assets/music/gameplay/Pixel 10.ogg"),
}, "environment": {
	"forest": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"dungeon": preload("res://assets/music/gameplay/Pixel 10.ogg"),
	"town": preload("res://assets/music/gameplay/Pixel 10.ogg"),
}}
## Primary audio stream player for main music
var _primary_player: AudioStreamPlayer
## Secondary audio stream player for crossfading
var _secondary_player: AudioStreamPlayer
## Tween for smooth volume transitions (legacy - now using individual tweens)
var _fade_tween: Tween
## Current music state
var _current_track_name: String = ""
var _current_category: String   = ""
var _is_playing: bool           = false
var _is_paused: bool            = false
var _should_loop: bool          = true
## Volume settings
var _master_music_volume: float = 1.0
## Default fade duration for transitions
const DEFAULT_FADE_DURATION: float = 1.0
## Default volume for music playback
const DEFAULT_VOLUME_DB: float = -10.0


## Initialize the music system
func _ready() -> void:
	_setup_audio_players()
	_setup_tween()


## Create and configure audio stream players
func _setup_audio_players() -> void:
	# Primary player setup
	_primary_player = AudioStreamPlayer.new()
	_primary_player.name = "PrimaryMusicPlayer"
	_primary_player.volume_db = DEFAULT_VOLUME_DB
	_primary_player.bus = "Music"  # Assumes you have a "Music" audio bus
	add_child(_primary_player)

	# Connect finished signal for auto-loop fallback
	_primary_player.finished.connect(_on_music_finished)

	# Secondary player setup for crossfading
	_secondary_player = AudioStreamPlayer.new()
	_secondary_player.name = "SecondaryMusicPlayer"
	_secondary_player.volume_db = DEFAULT_VOLUME_DB
	_secondary_player.bus = "Music"
	add_child(_secondary_player)


## Create and configure the fade tween
func _setup_tween() -> void:
	_fade_tween = create_tween()
	_fade_tween.kill()  # Stop it immediately, we'll create new ones as needed


## Validate if a music track exists
## @param category: The music category
## @param track_name: The track name within the category
## @return: True if the track exists, false otherwise
func _validate_music_track(category: String, track_name: String) -> bool:
	if not MUSIC_TRACKS.has(category):
		push_warning("Music category '%s' not found" % category)
		return false

	if not MUSIC_TRACKS[category].has(track_name):
		push_warning("Music track '%s' not found in category '%s'" % [track_name, category])
		return false

	return true


## Get music track by category and name
## @param category: The music category
## @param track_name: The track name within the category
## @return: The AudioStream resource, or null if not found
func _get_music_track(category: String, track_name: String) -> AudioStream:
	if not _validate_music_track(category, track_name):
		return null

	return MUSIC_TRACKS[category][track_name]


## Play music with optional fade in
## @param track_identifier: Either "category/track_name" or just "track_name" (searches all categories)
## @param fade_in_duration: Duration of fade in effect (0 for instant)
## @param loop: Whether the music should loop (default: true)
func play_music(track_identifier: String, fade_in_duration: float = 0.0, loop: bool = true) -> void:
	var parts: PackedStringArray = track_identifier.split("/")
	var category: String
	var track_name: String

	if parts.size() == 2:
		category = parts[0]
		track_name = parts[1]
	else:
		# Search for track in all categories
		var found_track: Dictionary = _find_track_in_all_categories(track_identifier)
		if found_track.is_empty():
			push_error("Music track '%s' not found in any category" % track_identifier)
			return
		category = found_track["category"]
		track_name = found_track["track_name"]

	var music_stream: AudioStream = _get_music_track(category, track_name)
	if not music_stream:
		push_error("Failed to load music stream for '%s/%s'" % [category, track_name])
		return

	# Stop current music if playing
	if _is_playing:
		_primary_player.stop()
		_secondary_player.stop()

	# Setup and play new music
	_primary_player.stream = music_stream

	# Set loop for OGG files
	if music_stream is AudioStreamOggVorbis:
		music_stream.loop = loop

	# Store loop preference for manual looping fallback
	_should_loop = loop

	_current_track_name = track_name
	_current_category = category
	_is_playing = true
	_is_paused = false

	if fade_in_duration > 0.0:
		_primary_player.volume_db = -80.0  # Start silent
		_primary_player.play()
		_fade_to_volume(_primary_player, _calculate_target_volume(), fade_in_duration)
	else:
		_primary_player.volume_db = _calculate_target_volume()
		_primary_player.play()


## Search for a track in all categories
## @param track_name: The track name to search for
## @return: Dictionary with category and track_name, or empty dict if not found
func _find_track_in_all_categories(track_name: String) -> Dictionary:
	for category in MUSIC_TRACKS.keys():
		if MUSIC_TRACKS[category].has(track_name):
			return {"category": category, "track_name": track_name}
	return {}


## Crossfade from current music to new music
## @param track_identifier: Target music track
## @param fade_duration: Duration of the crossfade
## @param loop: Whether the new music should loop
func crossfade_to_music(track_identifier: String, fade_duration: float = DEFAULT_FADE_DURATION, loop: bool = true) -> void:
	if not _is_playing:
		play_music(track_identifier, fade_duration, loop)
		return

	var parts: PackedStringArray = track_identifier.split("/")
	var category: String
	var track_name: String

	if parts.size() == 2:
		category = parts[0]
		track_name = parts[1]
	else:
		var found_track: Dictionary = _find_track_in_all_categories(track_identifier)
		if found_track.is_empty():
			push_error("Music track '%s' not found in any category" % track_identifier)
			return
		category = found_track["category"]
		track_name = found_track["track_name"]

	# Don't crossfade to the same track
	if category == _current_category and track_name == _current_track_name:
		return

	var new_music_stream: AudioStream = _get_music_track(category, track_name)
	if not new_music_stream:
		return

	# Setup secondary player with new music
	_secondary_player.stream = new_music_stream
	if new_music_stream.has_method("set_loop"):
		new_music_stream.set_loop(loop)

	_secondary_player.volume_db = -80.0
	_secondary_player.play()

	# Crossfade: fade out primary, fade in secondary
	_fade_to_volume(_primary_player, -80.0, fade_duration)
	_fade_to_volume(_secondary_player, _calculate_target_volume(), fade_duration)

	# Swap players after crossfade
	await _fade_tween.finished
	_primary_player.stop()

	# Swap the players
	var temp_player: AudioStreamPlayer = _primary_player
	_primary_player = _secondary_player
	_secondary_player = temp_player

	_current_track_name = track_name
	_current_category = category


## Stop music with optional fade out
## @param fade_out_duration: Duration of fade out effect (0 for instant)
func stop_music(fade_out_duration: float = 0.0) -> void:
	if not _is_playing:
		return

	if fade_out_duration > 0.0:
		_fade_to_volume(_primary_player, -80.0, fade_out_duration)
		await _fade_tween.finished

	_primary_player.stop()
	_secondary_player.stop()

	_is_playing = false
	_is_paused = false
	_current_track_name = ""
	_current_category = ""


## Pause the current music
func pause_music() -> void:
	if _is_playing and not _is_paused:
		_primary_player.stream_paused = true
		_is_paused = true


## Resume paused music
func resume_music() -> void:
	if _is_playing and _is_paused:
		_primary_player.stream_paused = false
		_is_paused = false


## Set master music volume
## @param volume: Volume level (0.0 to 1.0)
## @param fade_duration: Duration of volume change (0 for instant)
func set_volume(volume: float, fade_duration: float = 0.0) -> void:
	_master_music_volume = clamp(volume, 0.0, 1.0)

	var target_db: float = _calculate_target_volume()

	if fade_duration > 0.0 and _is_playing:
		_fade_to_volume(_primary_player, target_db, fade_duration)
	else:
		_primary_player.volume_db = target_db
		_secondary_player.volume_db = target_db


## Calculate target volume in decibels
## @return: Volume in decibels
func _calculate_target_volume() -> float:
	if _master_music_volume <= 0.0:
		return -80.0
	# More efficient calculation: avoid division
	return DEFAULT_VOLUME_DB + linear_to_db(_master_music_volume)


## Fade a player to target volume
## @param player: The AudioStreamPlayer to fade
## @param target_volume_db: Target volume in decibels
## @param duration: Fade duration
func _fade_to_volume(player: AudioStreamPlayer, target_volume_db: float, duration: float) -> void:
	# Kill existing tween and create a new one
	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()

	# Store reference to player for the tween callback
	var target_player: AudioStreamPlayer = player
	_fade_tween.tween_method(
		func(volume_db: float): target_player.volume_db = volume_db,
			player.volume_db,
			target_volume_db,
			duration
	)


## Helper method for tween volume changes (no longer needed but kept for compatibility)
## @param player: The AudioStreamPlayer to modify
## @param volume_db: Volume in decibels
func _set_player_volume(player: AudioStreamPlayer, volume_db: float) -> void:
	if is_instance_valid(player):
		player.volume_db = volume_db


## Handle music finished event for manual looping
func _on_music_finished() -> void:
	if _should_loop and _is_playing and not _is_paused:
		_primary_player.play()


## Public API for querying music state

## Check if music is currently playing
## @return: True if music is playing, false otherwise
func is_music_playing() -> bool:
	return _is_playing


## Check if music is currently paused
## @return: True if music is paused, false otherwise
func is_music_paused() -> bool:
	return _is_paused


## Get current music track information
## @return: Dictionary with category, track_name, and playing status
func get_current_music_info() -> Dictionary:
	return {
		"category": _current_category,
		"track_name": _current_track_name,
		"is_playing": _is_playing,
		"is_paused": _is_paused,
		"volume": _master_music_volume
	}


## Get all available music tracks
## @return: Dictionary of all available music tracks organized by category
func get_available_tracks() -> Dictionary:
	var available: Dictionary = {}
	for category in MUSIC_TRACKS.keys():
		available[category] = MUSIC_TRACKS[category].keys()
	return available


## Get current master volume
## @return: Current volume level (0.0 to 1.0)
func get_volume() -> float:
	return _master_music_volume
