class_name BaseLevelInputs
extends Node

signal move_requested(direction: Vector2i)
signal debug_grid_toggled()

var input_enabled: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if event.is_action_pressed("ui_up"):
		move_requested.emit(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		move_requested.emit(Vector2i.DOWN)
	elif event.is_action_pressed("ui_left"):
		move_requested.emit(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		move_requested.emit(Vector2i.RIGHT)
		
	if event.is_action_pressed("toggle_debug_grid"):
		debug_grid_toggled.emit()
