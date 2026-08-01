class_name GridWorld
extends Node2D

@export_group("Grid Configuration")
@export var grid_size: float = 32.0
@export var grid_bounds: Vector2i = Vector2i(50, 30)

@export_group("Debug Overlay")
@export var grid_line_color: Color = Color(1.0, 1.0, 1.0, 0.8)

var show_grid: bool = false

# Multi-object grid: Vector2i -> Array[GridObject]
var data_grid: Dictionary = {}

@onready var asteroid_container: Node2D = $AsteroidContainer
@onready var entity_container: Node2D = $EntityContainer
@onready var trail_line_container: Node2D = $TrailLineContainer

func _ready() -> void:
	# Keep overlay visible above entities when activated
	z_index = 100
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	# Toggle debug grid overlay with Spacebar / ui_accept
	if event.is_action("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		if event.is_pressed() and not event.is_echo():
			show_grid = true
			queue_redraw()
		elif not event.is_pressed():
			show_grid = false
			queue_redraw()

func _draw() -> void:
	if not show_grid:
		return
		
	for x in range(grid_bounds.x):
		for y in range(grid_bounds.y):
			var top_left = Vector2(x * grid_size, y * grid_size)
			var top_right = top_left + Vector2(grid_size, 0)
			var bottom_right = top_left + Vector2(grid_size, grid_size)
			var bottom_left = top_left + Vector2(0, grid_size)
			
			var points = PackedVector2Array([top_left, top_right, bottom_right, bottom_left, top_left])
			draw_polyline(points, grid_line_color, 0.8, true)

# --- Entity Management & Grid Logic ---

func add_object(pos: Vector2i, obj: GridObject) -> void:
	if not data_grid.has(pos):
		data_grid[pos] = []
	
	data_grid[pos].append(obj)
	obj.global_position = grid_to_world(pos)
	
	if obj is Asteroid:
		asteroid_container.add_child(obj)
	else:
		entity_container.add_child(obj)

func add_trail(trail_node : Line2D) -> void:
	trail_line_container.add_child(trail_node)	
	
func get_data_grid() -> Dictionary:
	return data_grid
	
func get_objects_at(pos: Vector2i) -> Array:
	return data_grid.get(pos, [])

func remove_object(pos: Vector2i, obj: GridObject) -> void:
	if data_grid.has(pos):
		data_grid[pos].erase(obj)
		if data_grid[pos].is_empty():
			data_grid.erase(pos)
	obj.queue_free()

func grid_to_world(pos: Vector2i) -> Vector2:
	return Vector2(pos.x * grid_size, pos.y * grid_size) + Vector2(grid_size / 2.0, grid_size / 2.0)

func is_inside_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_bounds.x and pos.y >= 0 and pos.y < grid_bounds.y
