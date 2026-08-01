class_name NetworkAnalyzer
extends RefCounted

static func find_farthest_points(asteroid_vectors: Array[Vector2i], scanner: GridScanner) -> Dictionary:
	var random_seed_pos: Vector2i = asteroid_vectors.pick_random()
	print("random seed:", random_seed_pos)
	var pass1_distances: Dictionary = calculate_bfs_distances(random_seed_pos, scanner)
	var player_start: Vector2i = get_furthest_node(pass1_distances)
	print("player_start:", player_start)
	var player_distances: Dictionary = calculate_bfs_distances(player_start, scanner)
	var target_end: Vector2i = get_furthest_node(player_distances)
	print("target_end:", target_end)
	
	return {
		"player_start": player_start,
		"target_end": target_end,
		"distances": player_distances
	}	
	
# Runs BFS from start_pos and returns a Dictionary: Vector2i -> int (distance)
static func calculate_bfs_distances(start_pos: Vector2i, scanner: GridScanner) -> Dictionary:
	
	var distances: Dictionary = {}
	var queue: Array[Vector2i] = [start_pos]
	distances[start_pos] = 0
	
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		var current_dist: int = distances[current]
		
		# Check movement in 4 orthogonal directions using your Scanner/Jump rules
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var scan_result: GridScanner.JumpResult = scanner.scan_jump(current, dir)
			if scan_result.state != GridScanner.JumpState.FAIL:
				var neighbor: Vector2i = scan_result.target_pos
				if not distances.has(neighbor):
					distances[neighbor] = current_dist + 1
					queue.append(neighbor)
					
	return distances

# Helper to find the node with the maximum distance
static func get_furthest_node(distances: Dictionary) -> Vector2i:
	if distances.is_empty():
		return Vector2i.ZERO
	var max_dist: int = -1
	var furthest_node: Vector2i = distances.keys()[0]
	
	for pos in distances:
		if distances[pos] > max_dist:
			max_dist = distances[pos]
			furthest_node = pos
			
	return furthest_node
