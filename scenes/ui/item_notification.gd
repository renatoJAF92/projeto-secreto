extends CanvasLayer

const SHOW_DURATION := 2.5
const ICON_FRAME_W := 205
const ICON_FRAME_H := 327

func setup(item_name: String, icon_texture: Texture2D) -> void:
	$Control/Panel/HBox/Icon.texture = icon_texture
	$Control/Panel/HBox/ItemLabel.text = "Obteve " + item_name + "!"
	get_tree().create_timer(SHOW_DURATION).timeout.connect(queue_free, CONNECT_ONE_SHOT)
