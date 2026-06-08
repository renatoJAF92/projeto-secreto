extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	layer = 100  # Acima de tudo, inclusive Dialogic (Pitfall 3)
	overlay.color = Color(0, 0, 0, 0)  # Invisível no início

func go_to(scene_path: String) -> void:
	var t := create_tween()
	t.tween_property(overlay, "color:a", 1.0, 0.3)
	await t.finished
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("[SceneTransition] change_scene_to_file FAILED: " + str(err) + " for path: " + scene_path)
		overlay.color.a = 0.0
		return
	await get_tree().process_frame
	await get_tree().process_frame
	t = create_tween()
	t.tween_property(overlay, "color:a", 0.0, 0.3)
	await t.finished
