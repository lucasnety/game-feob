
extends Control

@export var radius: float = 3
@export var color: Color = Color.WHITE
@export var size_box: Vector2 = Vector2(20, 20)

func _ready() -> void:
	# Centraliza o Control na tela
	set_anchors_preset(Control.PRESET_CENTER)
	custom_minimum_size = size_box
	queue_redraw()

func _draw() -> void:
	# Desenha uma bolinha no centro
	var center = Vector2(size_box.x / 2, size_box.y / 2)
	draw_circle(center, radius, color)

func set_targeted(is_targeted: bool) -> void:
	color = Color.RED if is_targeted else Color.WHITE
	queue_redraw()
