extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
enum State {
	IDLE,
	ENTERING_INTERACTION,
	INTERACTING,
	EXITING_INTERACTION
}
var current_state: State  = State.IDLE
var player_in_range: bool = false


func _ready() -> void:
	# Connecter les signaux
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

	if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	if not interaction_area.body_exited.is_connected(_on_interaction_area_body_exited):
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	# Commencer en idle
	animated_sprite.play("idle")


func _input(event: InputEvent) -> void:
	# Interaction avec E (ou F)
	if event.is_action_pressed("Interact") and player_in_range:
		_start_interaction()


func _start_interaction() -> void:
	if current_state == State.IDLE:
		current_state = State.ENTERING_INTERACTION
		animated_sprite.play("interacting_entry")
		print("Marchand: Bonjour ! Que puis-je faire pour vous ?")


func _end_interaction() -> void:
	if current_state == State.INTERACTING:
		current_state = State.EXITING_INTERACTION
		animated_sprite.play("interacting_rest")
		print("Marchand: À bientôt !")


func _on_animation_finished() -> void:
	match animated_sprite.animation:
		"interacting_entry":
			# Entrée terminée → commencer la boucle d'interaction
			current_state = State.INTERACTING
			animated_sprite.play("interacting_loop")

		"interacting_rest":
			# Sortie terminée → retour à l'idle
			current_state = State.IDLE
			animated_sprite.play("idle")


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("[E] Parler au marchand")


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		# Forcer la fin de l'interaction si le joueur s'éloigne
		if current_state == State.INTERACTING:
			_end_interaction()


# Fonction pour terminer l'interaction (à appeler depuis un menu/dialogue)
func close_interaction() -> void:
	_end_interaction()
