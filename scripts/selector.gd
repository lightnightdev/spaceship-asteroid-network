extends Node2D

var move_queue: Array[Vector2i] = []
var is_processing_queue: bool = false

const DIRECTIONS = {
	"ui_up": Vector2i.UP,
	"ui_down": Vector2i.DOWN,
	"ui_left": Vector2i.LEFT,
	"ui_right": Vector2i.RIGHT
}

@onready var visual: AnimatedSprite2D = $Sprite

func _ready() -> void:
	visual.play("default")

func _process(delta: float) -> void:
	for action in DIRECTIONS:
		if Input.is_action_just_pressed(action):
			_enqueue_move(DIRECTIONS[action])
			break # Prevents pressing multiple directions in same frame

func _enqueue_move(dir: Vector2i) -> void:
	move_queue.append(dir)
	
	if not is_processing_queue:
		_process_queue()

func _process_queue() -> void:
	is_processing_queue = true
	
	while move_queue.size() > 0:
		var next_move: Vector2i = move_queue.pop_front()
		_execute_move(next_move)
		# Pacing/Delay: allow visual execution before popping the next item
#		await get_tree().create_timer(step_delay).timeout
	
	is_processing_queue = false

func _execute_move(dir: Vector2i) -> void:
	print("Executing visual step: ", dir)
	# Update tilemap grid position or kick off a Tween here
