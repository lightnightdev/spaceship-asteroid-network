extends Node2D

@onready var visual: AnimatedSprite2D = $AnimatedSprite2D

var is_moving: bool = false
var move_tween: Tween

# Adjust sprite_angle_offset if your idle sprite faces UP or DOWN by default.
# Right = 0.0, Down = PI/2, Left = PI, Up = -PI/2
const SPRITE_ANGLE_OFFSET: float = PI / 2.0

func move_towards_dir(dir: Vector2i, target_world_pos: Vector2, duration: float = 0.5) -> void:
	if is_moving or dir == Vector2i.ZERO:
		return
		
	is_moving = true
	rotation = Vector2(dir).angle() + SPRITE_ANGLE_OFFSET
	
	visual.stop()
	visual.frame = 1
	
	if move_tween and move_tween.is_running():
		move_tween.kill()
		
	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target_world_pos, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	_run_moving_animation_loop(duration)
	
	await move_tween.finished
	
	is_moving = false
	visual.frame = 0


func _run_moving_animation_loop(duration: float) -> void:
	var toggle_frame: bool = false
	# Step frame speed proportionally to overall move speed
	var step_delay: float = clamp(duration / 4.0, 0.01, 0.1)
	
	while is_moving:
		visual.frame = 3 if toggle_frame else 2
		toggle_frame = not toggle_frame
		await get_tree().create_timer(step_delay).timeout
