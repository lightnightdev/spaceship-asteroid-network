class_name Asteroid
extends GridObject

@onready var visual: AnimatedSprite2D = $Visual
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var constant_rotation_speed: float = 0.0
var accumulated_time: float = 0.0

const ROTATION_INTERVAL: float = 0.1 # Update 10 times per second instead of 60+
const ANGLE_STEP: float = 2.0 # Degrees per step

func _ready():
	object_name = "asteroid"
	jump_type = JumpType.LAND
	
	var total_frames = visual.sprite_frames.get_frame_count(visual.animation)
	visual.frame = randi_range(0, total_frames - 1)
	
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

# Call this function when the player lands on this asteroid
func on_player_landed(Node2D) -> void:
	constant_rotation_speed = 0
	visual.play("landing_vibration") # Switch to landing animation
	await get_tree().create_timer(1.0).timeout # Wait, then...
	visual.play("default") # Back to idle

func on_player_departed(Node2D) -> void:
	reset_rotation()
	visual.play("leaving_vibration") # Switch to landing animation
	await get_tree().create_timer(1.0).timeout # Wait, then...
	visual.play("default") # Back to idle
