class_name LevelGenerator
extends RefCounted

var scanner: GridScanner

const GRID : Vector2i = Vector2i(35,30)
const POPULATE : float = 0.08
const POPULATE_VARIANCE : float = 0.01

static func generate_grid_object_positions(
		grid_dimensions: Vector2i,
		target_density: float = 0.08
	) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	# Clamp density to prevent division-by-zero or infinite loops
	target_density = clampf(target_density, 0.001, 0.999)
	
	var total_cells: int = grid_dimensions.x * grid_dimensions.y
	var width: int = grid_dimensions.x
	
	# Pre-calculate log denominator. 
	var log_prob: float = log(1.0 - target_density)
	
	var index: int = 0
	while index < total_cells:
		# Calculate how many cells to skip to achieve target density
		var skip: int = int(floor(log(randf()) / log_prob))
		index += skip + 1
		
		if index < total_cells:
			var pos = Vector2i(index % width, index / width)
			positions.append(pos)
			
	positions = NetworkCleaner.clean_grid(positions)

	return positions
