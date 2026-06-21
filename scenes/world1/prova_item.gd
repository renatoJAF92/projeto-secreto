extends Area2D

@export var prova_id: String = "prova_foto"
@export var display_name: String = "Item"

const NOTIFICATION_SCENE := preload("res://scenes/ui/item_notification.tscn")

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var provas: Array = SaveManager.current_save.get("provas_mundo1", [])
	if prova_id not in provas:
		provas.append(prova_id)
		SaveManager.current_save["provas_mundo1"] = provas
		SaveManager.save_game()

	AudioManager.play_sfx("prova_coletada")
	$CPUParticles2D.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	_show_notification()
	get_tree().create_timer(0.25, true).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func _show_notification() -> void:
	var icon_tex: Texture2D = ($Sprite2D as Sprite2D).texture
	var notif := NOTIFICATION_SCENE.instantiate()
	get_tree().root.add_child(notif)
	notif.setup(display_name, icon_tex)
