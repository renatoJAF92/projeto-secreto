extends CanvasLayer

@export var title_text: String = ""
@export var hold_seconds: float = 2.0

func _ready() -> void:
	layer = 50
	if title_text != "":
		$Anchor/Panel/Label.text = title_text
	modulate.a = 0.0
	_animate_in_out()

func _animate_in_out() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.4)
	t.tween_interval(hold_seconds)
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	t.tween_callback(queue_free)
