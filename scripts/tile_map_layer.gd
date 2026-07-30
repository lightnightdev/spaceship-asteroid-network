extends TileMapLayer

@export var chunk_size: Vector2i = Vector2i(20, 20)
@export var tile_source_id: int = 0

# If you want to pick randomly from ALL 64 tiles (8x8 grid):
@export var background_tile_coords: Array[Vector2i] = []

func _ready() -> void:
	# Optionally populate all 64 tiles dynamically if array is empty
	if background_tile_coords.is_empty():
		for x in range(8):
			for y in range(8):
				background_tile_coords.append(Vector2i(x, y))
				
	generate_random_background()

func generate_random_background() -> void:
	clear()
	
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			var cell_pos = Vector2i(x, y)
			var random_coord: Vector2i = background_tile_coords.pick_random()
			set_cell(cell_pos, tile_source_id, random_coord)
