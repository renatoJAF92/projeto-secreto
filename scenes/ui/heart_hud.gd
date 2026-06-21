extends CanvasLayer

const REGION_FULL: Rect2 = Rect2(0, 0, 421, 353)
const REGION_EMPTY: Rect2 = Rect2(1082, 0, 420, 353)

@onready var heart1: Sprite2D = $Heart1
@onready var heart2: Sprite2D = $Heart2
@onready var heart3: Sprite2D = $Heart3


func _ready() -> void:
	var player := get_parent()
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.hp)


func _on_hp_changed(new_hp: int) -> void:
	_set_heart(heart1, new_hp >= 1)
	_set_heart(heart2, new_hp >= 2)
	_set_heart(heart3, new_hp >= 3)


func _set_heart(heart: Sprite2D, full: bool) -> void:
	heart.region_rect = REGION_FULL if full else REGION_EMPTY
