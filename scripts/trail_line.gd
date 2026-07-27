extends Line2D

# Time in seconds for a line segment to completely fade away
const FADE_DURATION: float = 2.0

# Holds point metadata: Array of Dictionary { "pos": Vector2, "age": float }
var point_data: Array[Dictionary] = []

func add_trail_segment(from_pos: Vector2, to_pos: Vector2) -> void:
	# Add starting point if line is currently empty
	if points.size() == 0:
		add_point(from_pos)
		point_data.append({"pos": from_pos, "age": 0.0})
		
	# Add target endpoint
	add_point(to_pos)
	point_data.append({"pos": to_pos, "age": 0.0})

func _process(delta: float) -> void:
	if point_data.is_empty():
		return

	# Age all existing points
	var i = point_data.size() - 1
	while i >= 0:
		point_data[i]["age"] += delta
		
		# Remove points that have exceeded the 5-second lifespan
		if point_data[i]["age"] >= FADE_DURATION:
			point_data.remove_at(i)
			remove_point(i)
		i -= 1

	# Update line opacity based on the age of the newest point
	if point_data.size() > 0:
		var oldest_age = point_data[0]["age"]
		var alpha = clamp(1.0 - (oldest_age / FADE_DURATION), 0.0, 1.0)
		modulate.a = alpha

	# Free node when all segments have completely faded out
	if point_data.is_empty():
		queue_free()
