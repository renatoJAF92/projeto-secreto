extends Area2D

@export var prova_id: String = "tfg_pesquisa_campo"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Defensive read: use .get() with default to handle missing key
	var itens: Array = SaveManager.current_save.get("itens_tfg_mundo2", [])

	# Guard against duplicate collection
	if prova_id not in itens:
		itens.append(prova_id)
		SaveManager.current_save["itens_tfg_mundo2"] = itens
		SaveManager.save_game()

	AudioManager.play_sfx("prova_tfg_coletada")
	$CPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	get_tree().create_timer(0.25, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)
