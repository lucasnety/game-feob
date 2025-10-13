extends Node3D

@export var sensitivity: float = 0.2
@export var acceleration: float = 10.0

const MIN: float = -300.0
const MAX: float = 250.0

var cam_hor: float = 0.0
var cam_ver: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_hor -= event.relative.x * sensitivity
		cam_ver = clamp(cam_ver - event.relative.y * sensitivity, -90.0, 90.0) # limita a rotação vertical

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	cam_ver = clamp(cam_ver, MIN, MAX)
	$horizontal.rotation_degrees.y = lerp($horizontal.rotation_degrees.y, cam_hor, acceleration * delta)
	$horizontal/vertical.rotation_degrees.x = lerp($horizontal/vertical.rotation_degrees.x, cam_ver, acceleration * delta)
