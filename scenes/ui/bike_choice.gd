extends CanvasLayer

signal chose_bicycle(yes: bool)

@onready var _label: Label = $Panel/VBox/Label
@onready var _btn_sim: Button = $Panel/VBox/HBox/BtnSim
@onready var _btn_nao: Button = $Panel/VBox/HBox/BtnNao


func _ready() -> void:
	layer = 60
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chose_bicycle.connect(_on_choice_made)
	_btn_sim.pressed.connect(func(): chose_bicycle.emit(true))
	_btn_nao.pressed.connect(func(): chose_bicycle.emit(false))
	var tc := get_node_or_null("/root/TouchControls")
	if tc:
		tc.ui_mode = true


func _on_choice_made(_yes: bool) -> void:
	var tc := get_node_or_null("/root/TouchControls")
	if tc:
		tc.ui_mode = false
	queue_free()
