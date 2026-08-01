class_name BaseLevel
extends Node2D

var TARGET_COUNT: int = 3		

# Systems & Data
var win_conditions: Dictionary = {}
var scanner: GridScanner	

# Core Positions
var player_grid_pos: Vector2i
var selector_grid_pos: Vector2i
var asteroid_vectors: Array[Vector2i]

# Queue system
var selector_move_queue: Array[Vector2i] = []
var is_processing_queue: bool = false

# Preloads
var AsteroidScene = preload("res://scenes/entities/asteroid.tscn")
var TrailScene = preload("res://scenes/entities/trail_line.tscn")

const DIRECTIONS = {
	"ui_up": Vector2i.UP,
	"ui_down": Vector2i.DOWN,
	"ui_left": Vector2i.LEFT,
	"ui_right": Vector2i.RIGHT
}

# In BaseLevel.gd
@onready var grid_world: GridWorld = $GridWorld
@onready var player = $GridWorld/Player
@onready var selector = $GridWorld/Selector
@onready var camera: BaseCamera = $Camera2D

func _ready() -> void:
	if camera and grid_world:
		camera.setup_default_view(grid_world.grid_bounds, grid_world.grid_size)

func _enqueue_selector_move(dir: Vector2i) -> void:
	selector_move_queue.append(dir)
	if not is_processing_queue:
		_process_selector_queue()

func _process_selector_queue() -> void:
	is_processing_queue = true
	while selector_move_queue.size() > 0:
		var dir: Vector2i = selector_move_queue.pop_front()
		await _execute_step(dir)
	is_processing_queue = false

func _execute_step(dir: Vector2i) -> void:
	var result: GridScanner.JumpResult = scanner.scan_jump(selector_grid_pos, dir)
	var start_world_pos = grid_world.grid_to_world(selector_grid_pos)
	
	if result.state == GridScanner.JumpState.FAIL:
		var border_world_pos = _get_border_world_position(selector_grid_pos, dir)
		_spawn_invalid_trail_segment(start_world_pos, border_world_pos)
		return
		
	var to_grid_pos: Vector2i = result.target_pos
	var end_world_pos = grid_world.grid_to_world(to_grid_pos)
	
	# Move Selector
	selector_grid_pos = to_grid_pos
	selector.global_position = end_world_pos
		
	_spawn_trail_segment(start_world_pos, end_world_pos)

	# 1. Depart all objects at current cell
	for obj in grid_world.get_objects_at(player_grid_pos):
		obj.on_player_departed(player)

	# 2. Update player position & movement
	player_grid_pos = to_grid_pos
	await player.move_towards_dir(dir, end_world_pos, 0.1)

	# 3. Handle passed nodes
	for pos in result.triggered_positions:
		for obj in grid_world.get_objects_at(pos):
			if obj.has_method("on_player_passed"):
				obj.on_player_passed(player)

	# 4. Land on target objects
	for obj in grid_world.get_objects_at(to_grid_pos):
		obj.on_player_landed(player)

func spawn_asteroid_node(grid_pos: Vector2i) -> void:
	var asteroid_instance: GridObject = AsteroidScene.instantiate()
	grid_world.add_object(grid_pos, asteroid_instance)

func _get_border_world_position(from_grid_pos: Vector2i, dir: Vector2i) -> Vector2:
	var target_world = grid_world.grid_to_world(from_grid_pos)
	
	if dir == Vector2i.UP:
		target_world.y = 0.0
	elif dir == Vector2i.DOWN:
		target_world.y = float(grid_world.grid_bounds.y) * grid_world.grid_size
	elif dir == Vector2i.LEFT:
		target_world.x = 0.0
	elif dir == Vector2i.RIGHT:
		target_world.x = float(grid_world.grid_bounds.x) * grid_world.grid_size

	return target_world

func _spawn_trail_segment(from_pos: Vector2, to_pos: Vector2) -> void:
	var trail_instance = TrailScene.instantiate()
	grid_world.add_trail(trail_instance)
	trail_instance.add_trail_segment(from_pos, to_pos)

func _spawn_invalid_trail_segment(from_pos: Vector2, to_pos: Vector2) -> void:
	var trail_instance = TrailScene.instantiate()
	grid_world.add_trail(trail_instance)
	trail_instance.gradient = null
	trail_instance.default_color = Color(0.5, 0.0, 0.0, 1.0)
	trail_instance.add_trail_segment(from_pos, to_pos)
	trail_instance.FADE_DURATION = 0.5
