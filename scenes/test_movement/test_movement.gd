extends CanvasLayer

@onready var player = $"../Player"
@onready var state_label: Label = $StateLabel


func _process(_delta: float) -> void:
	state_label.text = (
		"vel: %.0f, %.0f\n" % [player.velocity.x, player.velocity.y]
		+ "on_floor: %s\n" % player.is_on_floor()
		+ "coyote: %d\n" % player._coyote_timer
		+ "jump_buf: %d\n" % player._jump_buffer_timer
		+ "dashing: %s\n" % player._is_dashing
		+ "invincible: %s\n" % player._is_invincible
		+ "hurt: %s\n" % player._is_hurt
	)
