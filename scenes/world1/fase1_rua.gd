extends Node2D

@export var fase_width: int = 6400

var _player: CharacterBody2D

@onready var exit_trigger: Area2D = $ExitTrigger
@onready var _tile_layer: TileMapLayer = $TileMapLayer

# Floor segments: [tile_col_start, tile_col_end] — must match StaticBody2D collision shapes
const _FLOOR_SEGMENTS: Array = [
	[0, 13], [17, 31], [35, 49], [54, 74], [78, 99],
	[103, 123], [127, 149], [153, 174], [178, 199],
]

# Lamp post at the last tile of each floor segment (before the gap)
const _LAMP_TILES: Array[int] = [13, 31, 49, 74, 99, 123, 149, 174]

# Trash scattered on floors: [tile_x, atlas_col (0=bags×3, 1=bags×2, 2=black_bin, 3=red_bin)]
const _TRASH_ITEMS: Array = [
	[4, 0], [9, 1], [20, 2], [27, 0],
	[38, 1], [45, 0], [63, 2], [71, 3],
	[83, 0], [91, 1], [109, 2], [119, 0],
	[133, 1], [143, 2], [159, 0], [169, 1],
	[183, 2], [193, 0],
]


func _ready() -> void:
	get_tree().debug_collisions_hint = false

	_tile_layer.tile_set = _tile_layer.tile_set.duplicate()
	_place_floor_tiles()
	_setup_extra_sources()
	_place_decorations()
	_spawn_buildings_sprite()
	_spawn_bottom_fill()

	_player = get_tree().get_first_node_in_group("player")
	if _player and _player.has_node("Camera2D"):
		_player.get_node("Camera2D").limit_right = fase_width

	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

	if _player and _player.has_signal("died"):
		_player.died.connect(_on_player_died)

	_restore_checkpoint_spawn()

func _place_floor_tiles() -> void:
	if not _tile_layer or not _tile_layer.tile_set:
		return
	for seg in _FLOOR_SEGMENTS:
		for tx in range(seg[0], seg[1] + 1):
			_tile_layer.set_cell(Vector2i(tx, 5), 0, Vector2i(1, 0))
			for base_row in range(6, 10):
				_tile_layer.set_cell(Vector2i(tx, base_row), 0, Vector2i(1, 1))

func _setup_extra_sources() -> void:
	if not _tile_layer.tile_set.has_source(1):
		var deco_tex := preload("res://assets/backgrounds/world1/decoration_32x32.png") as Texture2D
		var s1 := TileSetAtlasSource.new()
		s1.texture = deco_tex
		s1.texture_region_size = Vector2i(32, 32)
		for row in range(4):
			for col in range(9):
				s1.create_tile(Vector2i(col, row))
		_tile_layer.tile_set.add_source(s1, 1)

	if not _tile_layer.tile_set.has_source(2):
		var bld_tex := preload("res://assets/backgrounds/world1/building_tiles_32x32.png") as Texture2D
		var s2 := TileSetAtlasSource.new()
		s2.texture = bld_tex
		s2.texture_region_size = Vector2i(32, 32)
		for row in range(12):
			for col in range(22):
				s2.create_tile(Vector2i(col, row))
		_tile_layer.tile_set.add_source(s2, 2)

func _spawn_buildings_sprite() -> void:
	var tex := load("res://assets/backgrounds/world1/fase1_buildings_bg.png") as Texture2D
	if not tex:
		push_warning("fase1_buildings_bg.png not imported yet — open Godot editor to trigger reimport")
		return
	var img_h: float = tex.get_height()  # 221
	var scale_f := 0.38
	var seg_y: float = 160.0 - img_h * scale_f + 4.0

	for seg in _FLOOR_SEGMENTS:
		var seg_x: float = int(seg[0]) * 32.0
		var seg_w: float = (int(seg[1]) - int(seg[0]) + 1) * 32.0

		var sprite := Sprite2D.new()
		sprite.texture = tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		sprite.centered = false
		sprite.region_enabled = true
		# region width in texture pixels so the tile repeats naturally within this segment
		sprite.region_rect = Rect2(0, 0, seg_w / scale_f, img_h)
		sprite.scale = Vector2(scale_f, scale_f)
		sprite.position = Vector2(seg_x, seg_y)
		sprite.z_index = -1
		add_child(sprite)

func _spawn_bottom_fill() -> void:
	# Black strip fixed to screen bottom — covers parallax bleed below the floor tiles
	var cl := CanvasLayer.new()
	cl.layer = 10
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.anchor_left = 0.0
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.anchor_top = 1.0
	rect.offset_top = -14.0   # 14px strip at very bottom of screen
	rect.offset_bottom = 0.0
	cl.add_child(rect)
	add_child(cl)

func _place_decorations() -> void:
	# Lamp posts (3 tiles tall): head at row 2, pole at row 3, base at row 4 — stands on surface at row 5
	for tx in _LAMP_TILES:
		_tile_layer.set_cell(Vector2i(tx, 2), 1, Vector2i(7, 0))
		_tile_layer.set_cell(Vector2i(tx, 3), 1, Vector2i(7, 1))
		_tile_layer.set_cell(Vector2i(tx, 4), 1, Vector2i(7, 2))
	# Trash items sitting on the floor surface (tile row 4 = one row above surface)
	for item in _TRASH_ITEMS:
		_tile_layer.set_cell(Vector2i(item[0], 4), 1, Vector2i(item[1], 0))

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.go_to("res://scenes/world1/fase2_parque.tscn")

func _on_player_died() -> void:
	_respawn()

func _respawn() -> void:
	var cp_id = SaveManager.current_save.get("checkpoint_id", "")
	var scene_path = SaveManager.CHECKPOINT_SCENES.get(cp_id, get_tree().current_scene.scene_file_path)
	SceneTransition.go_to(scene_path)

func _restore_checkpoint_spawn() -> void:
	if not _player:
		return
	var saved_id = SaveManager.current_save.get("checkpoint_id", "")
	if saved_id.is_empty():
		return
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.get("checkpoint_id") == saved_id:
			_player.global_position = Vector2(cp.global_position.x + 24.0, cp.global_position.y - 16.0)
			return
