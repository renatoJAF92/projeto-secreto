extends Area2D

@export var checkpoint_id: String = "mundo1_fase1_cp1"

var _activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Player may spawn inside the area — check immediately
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if _activated:
		return
	if body.is_in_group("player"):
		_activated = true
		SaveManager.set_checkpoint(checkpoint_id)
		AudioManager.play_sfx("checkpoint")
		_play_activate_animation()


func _play_activate_animation() -> void:
	$AnimatedSprite2D.play("active")
	var t := create_tween()
	t.tween_property($AnimatedSprite2D, "scale", Vector2(1.3, 1.3), 0.1)
	t.tween_property($AnimatedSprite2D, "scale", Vector2(1.0, 1.0), 0.15)
