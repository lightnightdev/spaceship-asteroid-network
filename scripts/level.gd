extends Node2D

const GRID_SIZE: float = 32.0
const GRID_BOUNDS = Vector2i(50, 30) # Updated grid dimensions

var AsteroidScene = preload("res://scenes/asteroid.tscn")
var TrailScene = preload("res://scenes/trail_line.tscn")

var level_data_grid: Dictionary = {} # Vector2i -> GridObject
var scanner: GridScanner

# Grid Positions
var player_grid_pos: Vector2i
var selector_grid_pos: Vector2i

# Queue system
var selector_move_queue: Array[Vector2i] = []
var is_processing_queue: bool = false

const DIRECTIONS = {
	"ui_up": Vector2i.UP,
	"ui_down": Vector2i.DOWN,
	"ui_left": Vector2i.LEFT,
	"ui_right": Vector2i.RIGHT
}

# Camera controls configuration
const CAMERA_PAN_SPEED: float = 400.0
const CAMERA_ZOOM_SPEED: float = 0.5
const MIN_ZOOM: float = 0.2
const MAX_ZOOM: float = 3.0

@onready var asteroid_container = $AsteroidsContainer
@onready var player = $Player
@onready var target = $Target
@onready var selector = $Selector
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	scanner = GridScanner.new(GRID_BOUNDS, level_data_grid)
	
	# 1. Generate grid positions with 0.08 density
	var asteroid_vectors: Array[Vector2i] = LevelGenerator.generate_asteroid_positions(GRID_BOUNDS, 0.05)
	
	# 2. Pass generated points through NetworkCleaner to form a single network
	asteroid_vectors = NetworkCleaner.clean_grid(asteroid_vectors)
	
	# Spawn all clean network asteroids
	for vector in asteroid_vectors:
		spawn_asteroid_node(vector)
		
	
	var STARTING_VECTOR : Vector2i = asteroid_vectors.pick_random()

	player_grid_pos = STARTING_VECTOR
	selector_grid_pos = STARTING_VECTOR
	
	player.global_position = grid_to_world(STARTING_VECTOR)
	selector.global_position = grid_to_world(STARTING_VECTOR)
	
	if not selector_grid_pos in level_data_grid:
		spawn_asteroid_node(selector_grid_pos)
		
	target.global_position = grid_to_world(asteroid_vectors.pick_random())
	
	# 3. Center camera on level center
	_setup_default_camera()

func _setup_default_camera() -> void:
	if not camera:
		return
		
	# Calculate world center of the 35x30 grid
	var level_size_px = Vector2(GRID_BOUNDS) * GRID_SIZE
	camera.global_position = Vector2(0,0)
	
	# Fit level within view bounds
	var viewport_size = get_viewport_rect().size
	if viewport_size.x > 0 and viewport_size.y > 0:
		var zoom_factor = min(viewport_size.x / level_size_px.x, viewport_size.y / level_size_px.y)
		camera.zoom = Vector2(zoom_factor, zoom_factor)

func _process(delta: float) -> void:
	# Selector Movement Input
	for action in DIRECTIONS:
		if Input.is_action_just_pressed(action):
			_enqueue_selector_move(DIRECTIONS[action])
			break

	# Camera Control Inputs (IJKL Pan & 1/2 Zoom)
	_handle_camera_controls(delta)

func _handle_camera_controls(delta: float) -> void:
	if not camera:
		return
		
	# IJKL Panning
	var pan_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_I):
		pan_dir.y -= 1
	if Input.is_key_pressed(KEY_K):
		pan_dir.y += 1
	if Input.is_key_pressed(KEY_J):
		pan_dir.x -= 1
	if Input.is_key_pressed(KEY_L):
		pan_dir.x += 1
		
	if pan_dir != Vector2.ZERO:
		camera.global_position += pan_dir.normalized() * CAMERA_PAN_SPEED * delta / camera.zoom.x

	# 1 and 2 Keys Zooming
	var zoom_change = 0.0
	if Input.is_key_pressed(KEY_1): # Zoom In
		zoom_change += CAMERA_ZOOM_SPEED * delta
	if Input.is_key_pressed(KEY_2): # Zoom Out
		zoom_change -= CAMERA_ZOOM_SPEED * delta
		
	if zoom_change != 0.0:
		var new_zoom = clamp(camera.zoom.x + zoom_change, MIN_ZOOM, MAX_ZOOM)
		camera.zoom = Vector2(new_zoom, new_zoom)

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
	var result: Dictionary = scanner.scan_jump(selector_grid_pos, dir)
	if result.is_empty():
		return
		
	var start_world_pos = grid_to_world(selector_grid_pos)
	var target_grid_pos: Vector2i = result["target_pos"]
	var end_world_pos = grid_to_world(target_grid_pos)
	
	# Move Selector
	selector_grid_pos = target_grid_pos
	selector.global_position = end_world_pos
		
	# Spawn trail line between previous position and new position
	_spawn_trail_segment(start_world_pos, end_world_pos)

func _spawn_trail_segment(from_pos: Vector2, to_pos: Vector2) -> void:
	var trail_instance = TrailScene.instantiate()
	add_child(trail_instance)
	trail_instance.add_trail_segment(from_pos, to_pos)

func spawn_asteroid_node(grid_pos: Vector2i) -> void:
	var asteroid_instance = AsteroidScene.instantiate()
	asteroid_instance.global_position = grid_to_world(grid_pos)
	asteroid_container.add_child(asteroid_instance)
	level_data_grid[grid_pos] = asteroid_instance

func grid_to_world(pos: Vector2i) -> Vector2:
	return Vector2(pos.x * GRID_SIZE, pos.y * GRID_SIZE) + Vector2(GRID_SIZE / 2.0, GRID_SIZE / 2.0)
