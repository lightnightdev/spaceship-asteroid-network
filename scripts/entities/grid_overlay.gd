extends Node2D

@export var grid_bounds: Vector2i = Vector2i(50, 30)
@export var grid_size: float = 32.0
# High visibility bright red for testing
@export var grid_line_color: Color = Color(1.0, 1.0, 1.0, 0.8) 

var show_grid:bool = false

func _ready() -> void:
	# Force high z_index so it always draws above TileMaps/Backgrounds
	z_index = 100
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
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
			
			# antialiased = true allows fractional pixel blending
			draw_polyline(points, grid_line_color, 0.8, true)
