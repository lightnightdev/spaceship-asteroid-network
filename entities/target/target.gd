extends GridObject

@onready var visual: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
	jump_type = JumpType.PASS
	object_name = "target"
	# 1. Set initial states: 4x scale and 0 degrees rotation
	scale = Vector2(4.0, 4.0)
	rotation_degrees = 0.0
	
	# 2. Create the tween
	var tween = create_tween()
	
	# Parallel allows both scale and rotation to animate at the EXACT same time
	tween.set_parallel(true)
	
	# Shrink to 1x over 2 seconds
	tween.tween_property(self, "scale", Vector2.ONE, 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	# Rotate 90 degrees over 2 seconds
	tween.tween_property(self, "rotation_degrees", 90.0, 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 3. Trigger the animation when the tween finishes
	# set_parallel(true) automatically waits for BOTH properties to complete before firing 'finished'
	tween.chain().tween_callback(_on_shrink_finished)

func on_player_passed(player_node: Node2D) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2, 2), 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	# Chain a callback after both parallel steps finish
	tween.chain().tween_callback(queue_free)
	print("target hit")

func _on_shrink_finished() -> void:
	if visual:
		visual.play("default")
