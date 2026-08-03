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

@export var jump_type: JumpType = JumpType.LAND
@export var object_name: String = "Grid Object"

func on_player_landed(player_node: Node2D) -> void:
	pass

func on_player_passed(player_node: Node2D) -> void:
	pass
	
func on_player_departed(player_node: Node2D) -> void:
	pass
