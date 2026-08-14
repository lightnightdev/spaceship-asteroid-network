class_name GridObject
extends Node2D

# earth:		- landable, starting point
# asteroid:     - landable
# star:         - need to pass to win
# planet:		- landable, needs to land to win
# black-hole:	- blocks
# worm-hole:	- teleports

# Shared data across all placeable grid entities

enum JumpType {
	LAND,
	BLOCK,
	PASS,
	PORTAL
}

@export var grid_position: Vector2i

@export var jump_type: JumpType = JumpType.LAND
@export var object_name: String = "Grid Object"
@export var consume_on_trigger: bool = false

func on_player_landed(player_node: Node2D) -> void:
	pass

func on_player_passed(player_node: Node2D) -> void:
	pass
	
func on_player_departed(player_node: Node2D) -> void:
	pass

# Called by GridWorld inside remove_object()
func on_death() -> void:
	# 1. Disable collisions / processing if applicable so it can't be interacted with
	set_process(false)
	set_physics_process(false)

	# 2. Trigger animation (Example using a Tween fade out)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	# 3. Queue free once the animation finishes
	tween.finished.connect(queue_free)
