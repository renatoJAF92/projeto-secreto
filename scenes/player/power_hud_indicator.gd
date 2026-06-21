extends CanvasLayer

var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("PowerHUDIndicator: player not found in scene")
		return
	update_power_display()


func _physics_process(delta: float) -> void:
	if not player:
		return

	# Get current power state from player
	var current_power: String = player._current_power
	var power_cooldown: float = player._power_cooldown

	# Update color based on cooldown state
	if power_cooldown > 0.0:
		# On cooldown - grey tint
		$TextureRect.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		# Ready - full color
		$TextureRect.modulate = Color.WHITE

	# Update label to show power name
	match current_power:
		"sketch":
			$Label.text = "Sketch"
		"amor":
			$Label.text = "Amor"
		"":
			$Label.text = ""


func update_power_display() -> void:
	if not player:
		return

	var current_power: String = player._current_power

	match current_power:
		"sketch":
			$TextureRect.texture = load("res://assets/sprites/ui/power_sketch.png") if ResourceLoader.exists("res://assets/sprites/ui/power_sketch.png") else null
			$TextureRect.modulate = Color("#FF9500")
			$Label.text = "Sketch"
		"amor":
			$TextureRect.texture = load("res://assets/sprites/ui/power_amor.png") if ResourceLoader.exists("res://assets/sprites/ui/power_amor.png") else null
			$TextureRect.modulate = Color("#FF1493")
			$Label.text = "Amor"
		_:
			# No power unlocked - hide icon
			$TextureRect.texture = null
			$Label.text = ""
