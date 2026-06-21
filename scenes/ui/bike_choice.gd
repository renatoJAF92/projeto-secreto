extends CanvasLayer

signal chose_bicycle(yes: bool)

@onready var _label: Label = $Panel/VBox/Label
@onready var _btn_sim: Button = $Panel/VBox/HBox/BtnSim
@onready var _btn_nao: Button = $Panel/VBox/HBox/BtnNao


func _ready() -> void:
	layer = 60
	# All nodes in the chain must be ALWAYS so they work while tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Dim.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox/HBox.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox/HBox/BtnSim.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox/HBox/BtnNao.process_mode = Node.PROCESS_MODE_ALWAYS
	# Dim is decorative — must not consume touches meant for buttons.
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chose_bicycle.connect(_on_choice_made)
	_btn_sim.pressed.connect(func(): chose_bicycle.emit(true))
	_btn_nao.pressed.connect(func(): chose_bicycle.emit(false))
	# Tell touch_controls not to consume events while this dialog is open.
	var tc := get_node_or_null("/root/TouchControls")
	if tc:
		tc.ui_mode = true
	get_tree().paused = true


func _on_choice_made(_yes: bool) -> void:
	var tc := get_node_or_null("/root/TouchControls")
	if tc:
		tc.ui_mode = false
	get_tree().paused = false
	queue_free()
