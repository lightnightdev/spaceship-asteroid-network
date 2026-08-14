extends BaseLevel

var TargetScene = preload("res://entities/target/target.tscn")
var targets_grid_positions: Array[Vector2i] = []

func _ready() -> void:
	# Call super to handle BaseLevel initialization (e.g., Camera Setup)
	super._ready()

	# 1. Generate grid vector positions and spawn asteroid nodes
	asteroid_vectors = LevelGenerator.generate_grid_object_positions(grid_world.grid_bounds, 0.05)
	for vector in asteroid_vectors:
		spawn_asteroid_node(vector)

	# 2. Instantiate GridScanner using GridWorld bounds and level data
	scanner = GridScanner.new(grid_world.grid_bounds, grid_world.data_grid)
	
	# 3. Find furthest endpoints and distance mapping via NetworkAnalyzer
	var starting_vectors: Dictionary = NetworkAnalyzer.find_farthest_points(asteroid_vectors, scanner)

	player_grid_pos = starting_vectors["player_start"]
	selector_grid_pos = starting_vectors["player_start"]
	
	# Position player and selector entities in world space
	player.global_position = grid_world.grid_to_world(player_grid_pos)
	selector.global_position = grid_world.grid_to_world(player_grid_pos)
	
	# 4. Pick unique target positions (guaranteeing target_end is included)
	targets_grid_positions.append(starting_vectors["target_end"])
	
	var available_target_positions = asteroid_vectors.duplicate()
	available_target_positions.erase(starting_vectors["player_start"])
	available_target_positions.erase(starting_vectors["target_end"])
	available_target_positions.shuffle()
	
	var additional_pick_count = min(TARGET_COUNT - 1, available_target_positions.size())
	targets_grid_positions.append_array(available_target_positions.slice(0, additional_pick_count))

	# Spawn target entities into the GridWorld
	for target_pos in targets_grid_positions:
		spawn_target_node(target_pos)
		
	# 5. Display calculated distances on each asteroid node
	if starting_vectors.has("distances"):
		var distances: Dictionary = starting_vectors["distances"]
		for pos in asteroid_vectors:
			for obj in grid_world.get_objects_at(pos):
				if obj.has_method("set_distance_display"):
					obj.set_distance_display(distances.get(pos, -1))

func spawn_target_node(grid_pos: Vector2i) -> void:
	var target_instance: GridObject = TargetScene.instantiate()
	grid_world.add_object(grid_pos, target_instance)
