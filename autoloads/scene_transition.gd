extends CanvasLayer

@onready var overlay: ColorRect = $Overlay

var previous_scene: String = ""

func _ready() -> void:
	layer = 100
	overlay.color = Color(0, 0, 0, 0)

func go_to(scene_path: String) -> void:
	var current := get_tree().current_scene
	if current and not current.scene_file_path.is_empty():
		previous_scene = current.scene_file_path
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

func go_back() -> void:
	if previous_scene.is_empty():
		go_to("res://scenes/main_menu/main_menu.tscn")
		return
	go_to(previous_scene)
