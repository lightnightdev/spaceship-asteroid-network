class_name BaseCamera
extends Camera2D

@export var pan_speed: float = 400.0
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 0.2
@export var max_zoom: float = 3.0

func setup_default_view(grid_bounds: Vector2i, grid_size: float) -> void:
	var level_size_px = Vector2(grid_bounds) * grid_size
	var viewport_size = get_viewport_rect().size
	var zoom_factor = min(viewport_size.x / level_size_px.x, viewport_size.y / level_size_px.y)
	
	zoom = Vector2(zoom_factor, zoom_factor)
	global_position = level_size_px / 2.0

func _process(delta: float) -> void:
	_handle_panning(delta)
	_handle_zooming(delta)

func _handle_panning(delta: float) -> void:
	var pan_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_I): pan_dir.y -= 1
	if Input.is_key_pressed(KEY_K): pan_dir.y += 1
	if Input.is_key_pressed(KEY_J): pan_dir.x -= 1
	if Input.is_key_pressed(KEY_L): pan_dir.x += 1
		
	if pan_dir != Vector2.ZERO:
		global_position += pan_dir.normalized() * pan_speed * delta / zoom.x

func _handle_zooming(delta: float) -> void:
	var zoom_change = 0.0
	if Input.is_key_pressed(KEY_1): zoom_change += zoom_speed * delta
	if Input.is_key_pressed(KEY_2): zoom_change -= zoom_speed * delta
		
	if zoom_change != 0.0:
		var new_zoom = clamp(zoom.x + zoom_change, min_zoom, max_zoom)
		zoom = Vector2(new_zoom, new_zoom)
