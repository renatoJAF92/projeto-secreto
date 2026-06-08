extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	layer = 100  # Acima de tudo, inclusive Dialogic (Pitfall 3)
	overlay.color = Color(0, 0, 0, 0)  # Invisível no início

func go_to(scene_path: String) -> void:
	print("[SceneTransition] go_to: ", scene_path)
	# Fade to black
	var t := create_tween()
	t.tween_property(overlay, "color:a", 1.0, 0.3)
	await t.finished
	print("[SceneTransition] fade-to-black done, changing scene...")
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("[SceneTransition] change_scene_to_file FAILED: " + str(err) + " for path: " + scene_path)
		overlay.color.a = 0.0
		return
	await get_tree().process_frame
	await get_tree().process_frame
	print("[SceneTransition] scene loaded, fading in...")
	# Fade in
	t = create_tween()
	t.tween_property(overlay, "color:a", 0.0, 0.3)
	await t.finished
	print("[SceneTransition] transition complete.")
