extends Node2D

@onready var label: Label = $StatusLabel

func _ready() -> void:
	_update_label()

func _update_label() -> void:
	var save_status := "Sem save"
	if SaveManager.save_exists():
		var cp: String = SaveManager.current_save.get("checkpoint_id", "(none)")
		save_status = "checkpoint_id: %s" % cp
	label.text = "Save: %s" % save_status

func _on_checkpoint_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SaveManager.set_checkpoint("test_cp_01")
		label.text = "SALVO: test_cp_01"
