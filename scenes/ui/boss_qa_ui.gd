extends CanvasLayer

signal qa_completed
signal choice_made(is_correct: bool)

const QUESTIONS: Array = [
	{
		"text": "Primeira: o Renato está realmente comprometido com você?",
		"answers": [
			{"text": "Ah, ele está aqui, não está? (revira os olhos)", "correct": false},
			{"text": "Ele provou cada dia. Fez eu me sentir feliz e me deu comida e presentes.", "correct": true},
			{"text": "Espero que sim, mas a única certeza na vida é a morte.", "correct": false},
		]
	},
	{
		"text": "Segunda: ele é religioso?",
		"answers": [
			{"text": "Ele vem de uma família 'católica', mas tem a própria crença.", "correct": true},
			{"text": "Ele só acredita no Cthulhu", "correct": false},
			{"text": "Ele acredita na rapazeada", "correct": false},
		]
	},
	{
		"text": "Terceira: qual fenômeno físico é responsável por um lápis parecer quebrado quando colocado em um copo com água?",
		"answers": [
			{"text": "Ahn?", "correct": false},
			{"text": "Hmm... reflexão?", "correct": false},
			{"text": "Hmm... refração?", "correct": true},
		]
	}
]

var _current_question: int = 0
var _waiting: bool = false

@onready var question_label: Label = $Control/QuestionPanel/QuestionLabel
@onready var answers_box: VBoxContainer = $Control/AnswersBox

var _btn_style_normal: StyleBoxTexture
var _btn_style_hover: StyleBoxTexture


func _ready() -> void:
	visible = false
	# All nodes need ALWAYS so they work even if something pauses the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Control.process_mode = Node.PROCESS_MODE_ALWAYS
	$Control/BgDim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Control/AnswersBox.process_mode = Node.PROCESS_MODE_ALWAYS
	_build_button_styles()


func _build_button_styles() -> void:
	var tex: Texture2D = load("res://assets/ui/choice_button.png")

	_btn_style_normal = StyleBoxTexture.new()
	_btn_style_normal.texture = tex
	_btn_style_normal.texture_margin_left = 14
	_btn_style_normal.texture_margin_right = 22
	_btn_style_normal.texture_margin_top = 6
	_btn_style_normal.texture_margin_bottom = 6

	_btn_style_hover = StyleBoxTexture.new()
	_btn_style_hover.texture = tex
	_btn_style_hover.texture_margin_left = 14
	_btn_style_hover.texture_margin_right = 22
	_btn_style_hover.texture_margin_top = 6
	_btn_style_hover.texture_margin_bottom = 6
	_btn_style_hover.modulate_color = Color(1.0, 0.85, 0.5, 1.0)


func show_qa() -> void:
	_current_question = 0
	visible = true
	var tc := get_node_or_null("/root/TouchControls")
	if tc:
		tc.ui_mode = true
	_present_question()


func _present_question() -> void:
	var q: Dictionary = QUESTIONS[_current_question]
	question_label.text = q["text"]

	for child in answers_box.get_children():
		child.queue_free()

	for answer: Dictionary in q["answers"]:
		var btn := Button.new()
		btn.text = answer["text"]
		btn.custom_minimum_size = Vector2(270, 15)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.clip_text = false
		btn.add_theme_font_size_override(&"font_size", 7)
		btn.add_theme_color_override(&"font_color", Color(0.18, 0.13, 0.08))
		btn.add_theme_color_override(&"font_hover_color", Color(0.5, 0.25, 0.05))
		btn.add_theme_color_override(&"font_pressed_color", Color(0.18, 0.13, 0.08))
		btn.add_theme_stylebox_override(&"normal", _btn_style_normal)
		btn.add_theme_stylebox_override(&"hover", _btn_style_hover)
		btn.add_theme_stylebox_override(&"pressed", _btn_style_normal)
		btn.add_theme_stylebox_override(&"focus", _btn_style_normal)
		answers_box.add_child(btn)

		btn.process_mode = Node.PROCESS_MODE_ALWAYS
		var is_correct: bool = answer["correct"]
		btn.pressed.connect(func(): _on_answer(is_correct, btn))

	_waiting = true


func _on_answer(is_correct: bool, btn: Button) -> void:
	if not _waiting:
		return
	_waiting = false

	# Disable all buttons
	for child in answers_box.get_children():
		if child is Button:
			(child as Button).disabled = true

	# Highlight chosen
	btn.modulate = Color(1.0, 0.75, 0.3) if is_correct else Color(1.0, 0.4, 0.4)

	emit_signal("choice_made", is_correct)

	await get_tree().create_timer(0.6).timeout

	_current_question += 1
	if _current_question < QUESTIONS.size():
		_present_question()
	else:
		visible = false
		var tc := get_node_or_null("/root/TouchControls")
		if tc:
			tc.ui_mode = false
		emit_signal("qa_completed")
