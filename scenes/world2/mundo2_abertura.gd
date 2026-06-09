extends Node2D

@onready var skip_button: Button = $UILayer/SkipButton

const TIMELINE_ID := "mundo2_abertura"


func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)

	# Read the seen flag on startup so skip button appears on second+ play
	skip_button.visible = SaveManager.has_seen_cutscene(TIMELINE_ID)

	# Auto-start the timeline (no StartButton needed)
	Dialogic.start(TIMELINE_ID)
	await Dialogic.timeline_ended

	# Mark this cutscene as seen for next playthrough
	SaveManager.mark_cutscene_seen(TIMELINE_ID)
	SaveManager.save_game()

	# Clean up skip button and transition to fase1
	Dialogic.Inputs.auto_skip.enabled = false
	skip_button.visible = false

	SceneTransition.go_to("res://scenes/world2/fase1_campus.tscn")


func _on_skip_pressed() -> void:
	Dialogic.Inputs.auto_skip.enabled = true
	Dialogic.Inputs.auto_skip.time_per_event = 0.05
