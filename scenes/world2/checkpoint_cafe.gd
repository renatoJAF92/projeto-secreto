extends Area2D

@export var checkpoint_id: String = "mundo2_checkpoint_cafe"

var _activated: bool = false


func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated:
		return
	if body.is_in_group("player"):
		_activated = true
		SaveManager.set_checkpoint(checkpoint_id)
		# Heal player +1 HP
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(1)
		# Play activation SFX and animation
		AudioManager.play_sfx("checkpoint")
		_play_activate_animation()


func _play_activate_animation() -> void:
	var t := create_tween()
	t.tween_property($AnimatedSprite2D, "scale", Vector2(1.25, 1.25), 0.1)
	t.tween_property($AnimatedSprite2D, "scale", Vector2(1.0, 1.0), 0.15)
	$AnimatedSprite2D.modulate = Color("#E07020")
