extends Node2D

@onready var skip_button: Button = $SkipButton
@onready var start_button: Button = $StartButton

const TIMELINE_ID := "test_dialogue"


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	skip_button.pressed.connect(_on_skip_pressed)


func _on_start_pressed() -> void:
	start_cutscene(TIMELINE_ID)


func start_cutscene(timeline_name: String) -> void:
	if Dialogic.current_timeline != null:
		return

	skip_button.visible = SaveManager.has_seen_cutscene(timeline_name)

	Dialogic.start(timeline_name)
	await Dialogic.timeline_ended

	SaveManager.mark_cutscene_seen(timeline_name)
	Dialogic.Inputs.auto_skip.enabled = false
	skip_button.visible = false


func _on_skip_pressed() -> void:
	Dialogic.Inputs.auto_skip.enabled = true
	Dialogic.Inputs.auto_skip.time_per_event = 0.05
