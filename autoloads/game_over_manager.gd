extends CanvasLayer

const CHECKPOINT_SCENES: Dictionary = {
	"mundo1_fase1_cp1": "res://scenes/world1/fase1_rua.tscn",
	"mundo1_fase2_cp1": "res://scenes/world1/fase2_parque.tscn",
	"mundo1_fase3_cp1": "res://scenes/world1/fase3_restaurante.tscn",
	"mundo2_fase1_cp1": "res://scenes/world2/fase1_campus.tscn",
	"mundo2_fase2_cp1": "res://scenes/world2/fase2_atelie.tscn",
	"mundo2_fase3_cp1": "res://scenes/world2/fase3_madrugada.tscn",
}
const DEFAULT_SCENE := "res://scenes/world1/fase1_rua.tscn"

var _handling: bool = false
var _overlay: ColorRect
var _container: CenterContainer


func _ready() -> void:
	layer = 100
	_build_ui()
	get_tree().node_added.connect(_on_node_added)


func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.85)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)

	_container = CenterContainer.new()
	_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_container.visible = false
	add_child(_container)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_container.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.95, 0.15, 0.15))
	vbox.add_child(title)

	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(sep)

	var sub := Label.new()
	sub.text = "Voltando ao último checkpoint..."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(sub)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("player") and node.has_signal("died"):
		if not node.died.is_connected(_on_player_died):
			node.died.connect(_on_player_died, CONNECT_ONE_SHOT)


func _on_player_died() -> void:
	if _handling:
		return
	_handling = true
	Engine.time_scale = 1.0
	_show_game_over()


func _show_game_over() -> void:
	_overlay.modulate.a = 0.0
	_overlay.visible = true
	_container.modulate.a = 0.0
	_container.visible = true

	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(_container, "modulate:a", 1.0, 0.5)
	await tween.finished

	await get_tree().create_timer(1.8, true).timeout

	_overlay.visible = false
	_container.visible = false
	_handling = false

	SceneTransition.go_to(_get_checkpoint_scene())


func _get_checkpoint_scene() -> String:
	var cp: String = SaveManager.current_save.get("checkpoint_id", "")
	return CHECKPOINT_SCENES.get(cp, DEFAULT_SCENE)
