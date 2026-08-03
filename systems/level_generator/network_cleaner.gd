class_name NetworkCleaner
extends RefCounted

static func clean_grid(points: Array[Vector2i]) -> Array[Vector2i]:
	
	var networks: Array[Array] = find_networks(points)
	
	# Loop through adjacent network pairs: (0 & 1), (1 & 2), (2 & 3), etc.
	for i in range(networks.size() - 1):
		var net_a: Array = networks[i]
		var net_b: Array = networks[i + 1]
		
		# Pick a random point from each adjacent network
		var point_a: Vector2i = net_a.pick_random()
		var point_b: Vector2i = net_b.pick_random()
		
		# Create the L-shaped corner bridge
		var bridge_point: Vector2i
		if randf() < 0.5:
			bridge_point = Vector2i(point_a.x, point_b.y)
		else:
			bridge_point = Vector2i(point_b.x, point_a.y)
		
		# Add the new bridge point if it isn't already present
		if not points.has(bridge_point):
			points.append(bridge_point)

	return points

# Finds unique networks of Vector2i coordinates joined by X/Y coordinates.
static func find_networks(points: Array[Vector2i]) -> Array[Array]:
	if points.is_empty():
		return [[]]

	# Map X and Y to the indices of the points with those coordinates
	var x_map: Dictionary = {} # int -> Array[int] (indices)
	var y_map: Dictionary = {} # int -> Array[int] (indices)

	for i in range(points.size()):
		var p = points[i]
		if not x_map.has(p.x):
			x_map[p.x] = []
		x_map[p.x].append(i)

		if not y_map.has(p.y):
			y_map[p.y] = []
		y_map[p.y].append(i)

	# Union-Find (Disjoint Set)
	var network_parent: Array[int] = []
	network_parent.resize(points.size())
	for i in range(points.size()):
		network_parent[i] = i #starting off, each point is its own network

	var find = func(self_ref, i: int) -> int:
		if network_parent[i] == i:
			return i
		network_parent[i] = self_ref.call(self_ref, network_parent[i])
		return network_parent[i]

	var union = func(i: int, j: int) -> void:
		var root_i = find.call(find, i)
		var root_j = find.call(find, j)
		if root_i != root_j:
			network_parent[root_i] = root_j

	# Connect all points that share the same X coordinate
	for x in x_map:
		var indices: Array = x_map[x] # Array of the vectors
		for i in range(1, indices.size()):
			union.call(indices[0], indices[i])

	# Connect all points that share the same Y coordinate
	for y in y_map:
		var indices: Array = y_map[y]
		for i in range(1, indices.size()):
			union.call(indices[0], indices[i])

	# Group the points by their ultimate root parent
	var groups: Dictionary = {} # int (root) -> Array[Vector2i]
	for i in range(points.size()):
		var root = find.call(find, i)
		if not groups.has(root):
			groups[root] = []
		groups[root].append(points[i])

	# Convert dictionary of groups to an array of arrays
	var result: Array[Array] = []
	for root in groups:
		result.append(groups[root])

	return result

# NOT tested yet!
static func x_find_networks_with_blockers(points: Array[Vector2i], blockers: Dictionary) -> Array[Array]:
	if points.is_empty():
		return []

	# 1. Map points by Y (rows) and by X (columns)
	var y_map: Dictionary = {} # Y -> Array[Vector2i]
	var x_map: Dictionary = {} # X -> Array[Vector2i]
	var point_to_idx: Dictionary = {} # Vector2i -> int (for Union-Find lookup)

	for i in range(points.size()):
		var p = points[i]
		point_to_idx[p] = i
		
		if not y_map.has(p.y): y_map[p.y] = []
		y_map[p.y].append(p)
		
		if not x_map.has(p.x): x_map[p.x] = []
		x_map[p.x].append(p)

	# 2. Union-Find Initialization
	var parent: Array[int] = []
	parent.resize(points.size())
	for i in range(points.size()):
		parent[i] = i

	var find = func(self_ref, i: int) -> int:
		if parent[i] == i: return i
		parent[i] = self_ref.call(self_ref, parent[i])
		return parent[i]

	var union = func(i: int, j: int) -> void:
		var root_i = find.call(find, i)
		var root_j = find.call(find, j)
		if root_i != root_j:
			parent[root_i] = root_j

	# Helper function: checks if any blocker lies strictly between two coordinates on a straight line
	var is_blocked = func(p1: Vector2i, p2: Vector2i) -> bool:
		if p1.y == p2.y: # Horizontal check
			var min_x = min(p1.x, p2.x)
			var max_x = max(p1.x, p2.x)
			for x in range(min_x + 1, max_x):
				if blockers.has(Vector2i(x, p1.y)):
					return true
		elif p1.x == p2.x: # Vertical check
			var min_y = min(p1.y, p2.y)
			var max_y = max(p1.y, p2.y)
			for y in range(min_y + 1, max_y):
				if blockers.has(Vector2i(p1.x, y)):
					return true
		return false

	# 3. Process Horizontal Segments (Row-by-Row)
	for y in y_map:
		var row: Array = y_map[y]
		row.sort_custom(func(a, b): return a.x < b.x) # Sort left-to-right
		
		for i in range(row.size() - 1):
			var p1 = row[i]
			var p2 = row[i + 1]
			# If neighboring points on the same row aren't blocked, join them!
			if not is_blocked.call(p1, p2):
				union.call(point_to_idx[p1], point_to_idx[p2])

	# 4. Process Vertical Segments (Column-by-Column)
	for x in x_map:
		var col: Array = x_map[x]
		col.sort_custom(func(a, b): return a.y < b.y) # Sort top-to-bottom
		
		for i in range(col.size() - 1):
			var p1 = col[i]
			var p2 = col[i + 1]
			# If neighboring points on the same column aren't blocked, join them!
			if not is_blocked.call(p1, p2):
				union.call(point_to_idx[p1], point_to_idx[p2])

	# 5. Collect Groups
	var groups: Dictionary = {}
	for i in range(points.size()):
		var root = find.call(find, i)
		if not groups.has(root):
			groups[root] = []
		groups[root].append(points[i])

	var result: Array[Array] = []
	for root in groups:
		result.append(groups[root])

	return result
