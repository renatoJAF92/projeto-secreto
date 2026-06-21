extends Node2D

@export var fase_width: int = 8000

const DEATHS_FOR_BIKE: int = 5

# Floor segments [tile_col_start, tile_col_end] — 16px per tile, floor surface at tile row 10 (y=160)
const _FLOOR_SEGMENTS: Array = [
	[0,   90],  # x=0..1456
	[104, 120], # x=1664..1936 (small island)
	[134, 170], # x=2144..2736
	[184, 220], # x=2944..3536
	[234, 280], # x=3744..4496
	[294, 334], # x=4704..5360
	[348, 409], # x=5568..6560
	[423, 499], # x=6768..8000
]

# Decorations: [tile_x, type] — 0=tree, 1=bush, 2=flower, 3=stone1, 4=stone2
const _DECORATIONS: Array = [
	[4,  0], [12, 1], [20, 2], [28, 0], [36, 1], [44, 2],
	[52, 0], [60, 1], [68, 2], [76, 0], [84, 1],
	[106, 1], [112, 2], [118, 0],
	[136, 0], [142, 1], [150, 2], [158, 0], [166, 1],
	[186, 2], [192, 0], [198, 1], [206, 2], [214, 0],
	[236, 0], [244, 1], [252, 2], [260, 0], [268, 1], [276, 2],
	[296, 0], [304, 1], [312, 2], [320, 0], [328, 1],
	[350, 0], [360, 1], [370, 2], [380, 0], [390, 1], [400, 0],
	[425, 0], [435, 1], [445, 2], [455, 0], [465, 1],
	[475, 2], [485, 0], [492, 1],
]

const _TILE_GRASS_LEFT  := Vector2i(0, 0)
const _TILE_GRASS_MID   := Vector2i(1, 0)
const _TILE_GRASS_RIGHT := Vector2i(2, 0)
const _TILE_DIRT        := Vector2i(1, 1)
const _TILE_DIRT_LEFT   := Vector2i(0, 1)
const _TILE_DIRT_RIGHT  := Vector2i(2, 1)
const _SURFACE_ROW      := 10  # y=160

var _death_count: int = 0
var _transitioning: bool = false
var _player: CharacterBody2D

@onready var exit_trigger: Area2D = $ExitTrigger
@onready var _tile_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	get_tree().debug_collisions_hint = false

	_tile_layer.tile_set = _tile_layer.tile_set.duplicate()
	_setup_grassland_source()
	_place_floor_tiles()
	_spawn_decorations()
	_spawn_bottom_fill()

	_player = get_tree().get_first_node_in_group("player")
	if _player and _player.has_node("Camera2D"):
		_player.get_node("Camera2D").limit_right = fase_width

	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)

	if _player and _player.has_signal("died"):
		_player.died.connect(_on_player_died)

	if SaveManager.current_save.get("bicycle_active", false):
		_apply_bicycle_mode()

	_restore_checkpoint_spawn()


func _setup_grassland_source() -> void:
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/Multi_Platformer_Tileset_Original copia/GrassLand/Terrain/Grassland_Terrain_Tileset.png") as Texture2D
	src.texture_region_size = Vector2i(16, 16)
	for row in range(8):
		for col in range(11):
			src.create_tile(Vector2i(col, row))
	if _tile_layer.tile_set.has_source(0):
		_tile_layer.tile_set.remove_source(0)
	_tile_layer.tile_set.add_source(src, 0)


func _place_floor_tiles() -> void:
	for seg in _FLOOR_SEGMENTS:
		var x0: int = int(seg[0])
		var x1: int = int(seg[1])
		_tile_layer.set_cell(Vector2i(x0, _SURFACE_ROW), 0, _TILE_GRASS_LEFT)
		for tx in range(x0 + 1, x1):
			_tile_layer.set_cell(Vector2i(tx, _SURFACE_ROW), 0, _TILE_GRASS_MID)
		_tile_layer.set_cell(Vector2i(x1, _SURFACE_ROW), 0, _TILE_GRASS_RIGHT)
		for ty in range(_SURFACE_ROW + 1, _SURFACE_ROW + 5):
			_tile_layer.set_cell(Vector2i(x0, ty), 0, _TILE_DIRT_LEFT)
			for tx in range(x0 + 1, x1):
				_tile_layer.set_cell(Vector2i(tx, ty), 0, _TILE_DIRT)
			_tile_layer.set_cell(Vector2i(x1, ty), 0, _TILE_DIRT_RIGHT)


func _spawn_decorations() -> void:
	var base := "res://assets/Multi_Platformer_Tileset_Original copia/GrassLand/Details/"
	var textures: Array[Texture2D] = [
		load(base + "GrassLand_Tree.png"),
		load(base + "GrassLand_Bush.png"),
		load(base + "GrassLand_Flower.png"),
		load(base + "GrassLand_Stone_1.png"),
		load(base + "GrassLand_Stone_2.png"),
	]
	var heights: Array[float] = [80.0, 16.0, 16.0, 8.0, 8.0]

	for item in _DECORATIONS:
		var tx: int = int(item[0])
		var kind: int = int(item[1])
		var on_floor := false
		for seg in _FLOOR_SEGMENTS:
			if tx >= int(seg[0]) and tx <= int(seg[1]):
				on_floor = true
				break
		if not on_floor:
			continue
		var tex := textures[kind]
		if not tex:
			continue
		var sprite := Sprite2D.new()
		sprite.texture = tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.centered = false
		sprite.position = Vector2(tx * 16.0, 160.0 - heights[kind])
		sprite.z_index = -1
		add_child(sprite)


func _spawn_bottom_fill() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 10
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.anchor_left = 0.0
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.anchor_top = 1.0
	rect.offset_top = -14.0
	rect.offset_bottom = 0.0
	cl.add_child(rect)
	add_child(cl)


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _transitioning:
		_transitioning = true
		SaveManager.current_save["bicycle_active"] = false
		SaveManager.current_save["fase2_deaths"] = 0
		SaveManager.save_game()
		SceneTransition.go_to("res://scenes/world1/fase3_restaurante.tscn")


func _on_player_died() -> void:
	_death_count = SaveManager.current_save.get("fase2_deaths", 0) + 1
	SaveManager.current_save["fase2_deaths"] = _death_count
	SaveManager.save_game()
	if _death_count >= DEATHS_FOR_BIKE and not SaveManager.current_save.get("bicycle_active", false):
		_show_bike_choice()
	else:
		_respawn()


func _show_bike_choice() -> void:
	GameOverManager.cancel()
	var choice_scene = preload("res://scenes/ui/bike_choice.tscn")
	var dialog = choice_scene.instantiate()
	add_child(dialog)
	dialog.chose_bicycle.connect(_on_bike_choice_made)


func _on_bike_choice_made(yes: bool) -> void:
	if yes:
		SaveManager.current_save["bicycle_active"] = true
		SaveManager.save_game()
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


func _apply_bicycle_mode() -> void:
	if not _player:
		return
	if _player.has_method("enable_bicycle_mode"):
		_player.enable_bicycle_mode()
