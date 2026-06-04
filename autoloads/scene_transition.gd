extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	layer = 100  # Acima de tudo, inclusive Dialogic (Pitfall 3)
	overlay.color = Color(0, 0, 0, 0)  # Invisível no início

func go_to(scene_path: String) -> void:
	# Fade to black
	var t := create_tween()
	t.tween_property(overlay, "color:a", 1.0, 0.3)
	await t.finished
	# Troca de cena (stall acontece aqui, coberto pelo preto)
	# scene_changed não existe no Godot 4 — aguarda 2 frames para a cena carregar
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	# Fade in
	t = create_tween()
	t.tween_property(overlay, "color:a", 0.0, 0.3)
	await t.finished
