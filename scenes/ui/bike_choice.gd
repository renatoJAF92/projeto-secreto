extends CanvasLayer

signal chose_bicycle(yes: bool)

@onready var _label: Label = $Panel/VBox/Label
@onready var _btn_sim: Button = $Panel/VBox/HBox/BtnSim
@onready var _btn_nao: Button = $Panel/VBox/HBox/BtnNao


func _ready() -> void:
	layer = 60
	chose_bicycle.connect(_on_choice_made)
	_btn_sim.pressed.connect(func(): chose_bicycle.emit(true))
	_btn_nao.pressed.connect(func(): chose_bicycle.emit(false))
	get_tree().paused = true


func _on_choice_made(_yes: bool) -> void:
	get_tree().paused = false
	queue_free()
