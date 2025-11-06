extends Node3D

@export var sensitivity: float = 0.2
@export var acceleration: float = 10.0
@export var distancia_max: float = 20.0

const MIN: float = -300.0
const MAX: float = 250.0

var cam_hor: float = 0.0
var cam_ver: float = 0.0
var mira: Control
var cam: Camera3D

var camera_ativa: bool = true
var inventario_aberto: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mira = $"../CanvasLayer/Control"
	cam = $horizontal/vertical/SpringArm3D/Camera3D

	var player = get_parent()
	if player.has_signal("toggle_inventory"):
		player.connect("toggle_inventory", Callable(self, "_on_toggle_inventory"))

# 🔹 Chamado quando o portal trava/destrava a câmera
func _on_portal_camera_locked(is_locked: bool) -> void:
	camera_ativa = not is_locked
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_locked else Input.MOUSE_MODE_CAPTURED)

func _on_toggle_inventory() -> void:
	inventario_aberto = !inventario_aberto
	camera_ativa = not inventario_aberto
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if not camera_ativa else Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		camera_ativa = !camera_ativa
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if camera_ativa else Input.MOUSE_MODE_VISIBLE)
		return

	if not camera_ativa:
		return

	if event is InputEventMouseMotion:
		cam_hor -= event.relative.x * sensitivity
		cam_ver = clamp(cam_ver - event.relative.y * sensitivity, -90.0, 90.0)

func _physics_process(delta: float) -> void:
	if not camera_ativa:
		return

	cam_ver = clamp(cam_ver, MIN, MAX)
	$horizontal.rotation_degrees.y = lerp($horizontal.rotation_degrees.y, cam_hor, acceleration * delta)
	$horizontal/vertical.rotation_degrees.x = lerp($horizontal/vertical.rotation_degrees.x, cam_ver, acceleration * delta)
