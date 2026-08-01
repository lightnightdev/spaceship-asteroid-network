class_name GridScanner
extends RefCounted

enum JumpState { FAIL, LAND, BLOCK }

var grid_bounds: Vector2i
var level_data: Dictionary # Vector2i -> Array[GridObject]

class JumpResult extends RefCounted:
	var state: JumpState = JumpState.FAIL
	var target_pos: Vector2i
	var triggered_positions: Array[Vector2i] = []
	func _init(p_state: JumpState, p_target_pos: Vector2i, p_triggered: Array[Vector2i] = []):
		state = p_state
		target_pos = p_target_pos
		triggered_positions = p_triggered

func _init(grid_bounds_: Vector2i, level_data_: Dictionary):
	grid_bounds = grid_bounds_
	level_data = level_data_

func is_inside_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_bounds.x and pos.y >= 0 and pos.y < grid_bounds.y

# Scans linearly in direction until it hits a blocking GridObject or leaves grid bounds
func scan_jump(origin_pos: Vector2i, direction: Vector2i) -> JumpResult:
	var triggered_positions: Array[Vector2i] = []
	var curr_pos: Vector2i = origin_pos + direction
	var last_valid_pos: Vector2i = origin_pos

	while is_inside_bounds(curr_pos):
		if curr_pos in level_data:
			var cell_objects: Array = level_data[curr_pos]
			var is_land: bool = false
			var is_block: bool = false
			var pass_count: int = 0
			
			for obj in cell_objects:
				match obj.jump_type:
					GridObject.JumpType.BLOCK:
						is_block = true
					GridObject.JumpType.LAND, GridObject.JumpType.PORTAL:
						is_land = true
					GridObject.JumpType.PASS:
						pass_count += 1

			if pass_count > 0:
				triggered_positions.append(curr_pos)
			if is_block:
				return JumpResult.new(JumpState.BLOCK, last_valid_pos, triggered_positions)
			if is_land:
				return JumpResult.new(JumpState.LAND, curr_pos, triggered_positions)
		last_valid_pos = curr_pos
		curr_pos += direction

	return JumpResult.new(JumpState.FAIL, last_valid_pos, triggered_positions)
