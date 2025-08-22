extends Control

const DialogueButtonPreload: PackedScene = preload("res://scenes/dialogue_button.tscn")
@onready var DialogueLabel: RichTextLabel = $HBoxContainer/VBoxContainer/RichTextLabel

var dialogue: Array[DE]
var current_dialogue_item: int = 0
var next_item: bool            = true
var player_node: CharacterBody2D


func _ready() -> void:
	visible = false
	$HBoxContainer/VBoxContainer/button_container.visible = false
	_find_player()


func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group('player')
	if players.size() > 0:
		player_node = players[0]
	else:
		call_deferred("_find_player")


func _process(_delta: float) -> void:
	if current_dialogue_item == dialogue.size():
		if !player_node:
			_find_player()
			return
		player_node.can_move = true
		queue_free()
		return

	if next_item:
		next_item = false
		var i: DE = dialogue[current_dialogue_item]

		if i is DialogueFunction:
			if i.hide_dialogue_box:
				visible = false
			else:
				visible = true
			_function_resource(i)

		elif i is DialogueChoice:
			visible = true
			_choice_resource(i)

		elif i is DialogueText:
			visible = true
			_text_resource(i)

		else:
			printerr("You accidentally added a DE resource!")
			current_dialogue_item += 1
			next_item = true


func _animate_text(text: String, speed: float, audio_stream: AudioStream = null, volume_db: int = -8, pitch_min: float = 0.85, pitch_max: float = 1.15) -> void:
	DialogueLabel.visible_characters = 0
	DialogueLabel.text = text

	if audio_stream:
		$AudioStreamPlayer.stream = audio_stream
		$AudioStreamPlayer.volume_db = volume_db

	var text_without_brackets: String = _text_without_square_brackets(text)
	var total_characters: int         = text_without_brackets.length()
	var character_timer: float        = 0.0

	while DialogueLabel.visible_characters < total_characters:
		if Input.is_action_just_pressed('Interact'):
			DialogueLabel.visible_characters = total_characters
			break

		character_timer += get_process_delta_time()
		if character_timer >= (1.0 / speed) or text_without_brackets[DialogueLabel.visible_characters] == " ":
			var character: String = text_without_brackets[DialogueLabel.visible_characters]
			DialogueLabel.visible_characters += 1

			if character != " " and audio_stream:
				$AudioStreamPlayer.pitch_scale = randf_range(pitch_min, pitch_max)
				$AudioStreamPlayer.play()

			character_timer = 0.0

		await get_tree().process_frame


func _function_resource(i: DialogueFunction) -> void:
	var target_node: Node = get_node_or_null(i.target_path)
	if not target_node:
		push_error("Target node not found: " + str(i.target_path))
		current_dialogue_item += 1
		next_item = true
		return

	if not target_node.has_method(i.function_name):
		push_error("Method not found: " + i.function_name + " on " + str(target_node))
		current_dialogue_item += 1
		next_item = true
		return

	if i.function_arguments.size() == 0:
		target_node.call(i.function_name)
	else:
		target_node.callv(i.function_name, i.function_arguments)

	if i.wait_for_signal_to_continue:
		var signal_name: String = i.wait_for_signal_to_continue
		if target_node.has_signal(signal_name):
			var signal_state: Dictionary = { "done": false }
			var callable                 = func(_args): signal_state.done = true
			target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
			while not signal_state.done:
				await get_tree().process_frame

	current_dialogue_item += 1
	next_item = true


func _choice_resource(i: DialogueChoice) -> void:
	await _animate_text(i.text, i.text_speed, i.text_sound, i.text_volume_db, i.text_volume_pitch_min, i.text_volume_pitch_max)

	$HBoxContainer/VBoxContainer/button_container.visible = true

	for item in i.choice_text.size():
		var DialogueButtonVar: Node = DialogueButtonPreload.instantiate()
		DialogueButtonVar.text = i.choice_text[item]

		var function_resource: DialogueFunction = i.choice_function_call[item]
		if function_resource:
			DialogueButtonVar.connect("pressed",
			Callable(get_node(function_resource.target_path), function_resource.function_name).bindv(function_resource.function_arguments),
			CONNECT_ONE_SHOT)
			if function_resource.hide_dialogue_box:
				DialogueButtonVar.connect("pressed", hide, CONNECT_ONE_SHOT)

			DialogueButtonVar.connect("pressed",
			_choice_button_pressed.bind(get_node(function_resource.target_path), function_resource.wait_for_signal_to_continue),
			CONNECT_ONE_SHOT)
		else:
			DialogueButtonVar.connect("pressed", _choice_button_pressed.bind(null, ""), CONNECT_ONE_SHOT)

		$HBoxContainer/VBoxContainer/button_container.add_child(DialogueButtonVar)
	$HBoxContainer/VBoxContainer/button_container.get_child(0).grab_focus()


func _text_resource(i: DialogueText) -> void:
	var camera_tween: Tween = null
	var camera: Camera2D    = get_viewport().get_camera_2d()
	if camera and i.camera_position != Vector2(999.999, 999.999):
		var target_position: Vector2 = i.camera_position

		if i.camera_position == Vector2(-1, -1):
			if player_node:
				target_position = player_node.global_position
			else:
				_find_player()
				if player_node:
					target_position = player_node.global_position
				else:
					target_position = Vector2(999.999, 999.999)

		if target_position != Vector2(999.999, 999.999):
			camera_tween = create_tween().set_trans(Tween.TRANS_SINE)
			camera_tween.tween_property(camera, "global_position", target_position, i.camera_transition_time)

	await _animate_text(i.text, i.text_speed, i.text_sound, i.text_volume_db, i.text_volume_pitch_min, i.text_volume_pitch_max)

	while true:
		await get_tree().process_frame
		if DialogueLabel.visible_characters == _text_without_square_brackets(i.text).length():
			if Input.is_action_just_pressed('Interact'):
				if camera_tween and camera_tween.is_valid():
					await camera_tween.finished

				current_dialogue_item += 1
				next_item = true
				break


func _choice_button_pressed(target_node: Node, wait_for_signal_to_continue: String):
	$HBoxContainer/VBoxContainer/button_container.visible = false
	for i in $HBoxContainer/VBoxContainer/button_container.get_children():
		i.queue_free()

	if wait_for_signal_to_continue:
		var signal_name: String = wait_for_signal_to_continue
		if target_node and target_node.has_signal(signal_name):
			var signal_state: Dictionary = { "done": false }
			var callable                 = func(_args): signal_state.done = true
			target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
			while not signal_state.done:
				await get_tree().process_frame

	current_dialogue_item += 1
	next_item = true


func _text_without_square_brackets(text: String) -> String:
	var result: String    = ""
	var in_brackets: bool = false
	for i in text:
		if i == "[":
			in_brackets = true
			continue
		elif i == "]":
			in_brackets = false
			continue
		elif not in_brackets:
			result += i
	return result
