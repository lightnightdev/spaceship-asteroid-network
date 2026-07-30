class_name Asteroid
extends GridObject

@onready var visual: AnimatedSprite2D = $Visual
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var constant_rotation_speed: float = 0.0
var accumulated_time: float = 0.0
var initial_frame: int = 0 # Store the initial frame index
var is_visited: bool = false

const ROTATION_INTERVAL: float = 0.05
const ANGLE_STEP: float = 2.0

func _ready():
	object_name = "asteroid"
	jump_type = JumpType.LAND
	
	# Pick random initial frame and SAVE it
	var total_frames = visual.sprite_frames.get_frame_count("default")
	initial_frame = randi_range(0, total_frames - 1)
	visual.frame = initial_frame
	
	rotation_degrees = randf_range(0, 360)
	reset_rotation()

func _process(delta: float) -> void:
	if not (notifier and notifier.is_on_screen()):
		return
		
	accumulated_time += delta
	if accumulated_time >= ROTATION_INTERVAL:
		accumulated_time -= ROTATION_INTERVAL
		# Snap to discrete 15-degree steps
		rotation_degrees = fmod(rotation_degrees + (sign(constant_rotation_speed) * ANGLE_STEP), 360.0)

func reset_rotation():
	constant_rotation_speed = randf_range(-150.0, 150.0)

func on_player_landed(player_node: Node2D) -> void:
	constant_rotation_speed = 0
	if not is_visited:
		is_visited = true
		darken_asteroid()

func darken_asteroid() -> void:
	# Multiply current RGB values by 0.75 (25% darker)
	# Modulate multiplies every pixel's color values by this color
	modulate.r *= 0.5
	modulate.g *= 0.5
	modulate.b *= 0.5

func on_player_departed(player_node: Node2D) -> void:
	reset_rotation()
