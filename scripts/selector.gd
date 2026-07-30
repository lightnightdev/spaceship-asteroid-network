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
	visual.visible = false
	#visual.play("default")
