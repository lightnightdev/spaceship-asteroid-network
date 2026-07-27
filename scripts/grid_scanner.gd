class_name GridScanner
extends RefCounted

var grid_bounds: Vector2i
var level_data: Dictionary

func _init(grid_bounds_: Vector2i, level_data_: Dictionary):
	grid_bounds = grid_bounds_
	level_data = level_data_

func is_inside_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_bounds.x and pos.y >= 0 and pos.y < grid_bounds.y

# Scans linearly in direction until it hits a GridObject or leaves grid bounds
func scan_jump(origin_pos: Vector2i, direction: Vector2i) -> Dictionary:
	var check_pos = origin_pos + direction
	
	while is_inside_bounds(check_pos):
		if check_pos in level_data:
			# Found a hit! Return both position AND the target node
			return {
				"target_pos": check_pos,
				"object": level_data[check_pos]
			}
		check_pos += direction
	
	# Out of bounds / hit nothing in the void
	return {}
