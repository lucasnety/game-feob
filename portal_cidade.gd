extends Node3D

signal camera_locked(is_locked: bool)

@onready var area = $Area3D
@onready var label_m = $CanvasLayer/Label
@onready var loading_panel = $CanvasLayer/LoadingPanel

var player_dentro = false
var player_ref: CharacterBody3D = null
var camera_travada: bool = false
var spawn_point: Marker3D = null

func _ready():
	label_m.visible = false
	if loading_panel:
		loading_panel.visible = false

	# tenta achar o Marker3D chamado "Spawn" dentro da cena atual
	spawn_point = get_tree().current_scene.find_child("Spawn", true, false)
	if not spawn_point:
		push_warning("⚠️ Não encontrei o Marker3D 'Spawn' na cena! Verifique se está como filho do World.")

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_dentro = true
		player_ref = body
		label_m.visible = true

		# conecta o sinal de travar câmera
		var camera_node = player_ref.get_node_or_null("camera")
		if camera_node and not is_connected("camera_locked", Callable(camera_node, "_on_portal_camera_locked")):
			connect("camera_locked", Callable(camera_node, "_on_portal_camera_locked"))

func _on_body_exited(body):
	if body.name == "Player":
		player_dentro = false
		label_m.visible = false
		_hide_mouse_and_unlock_camera()

func _process(_delta):
	if player_dentro and Input.is_action_just_pressed("interact"):
		_teleport_to_spawn()

func _teleport_to_spawn():
	if not player_ref or not spawn_point:
		push_warning("⚠️ Player ou Spawn não encontrados, não foi possível teleportar.")
		return

	label_m.visible = false
	_show_mouse_and_lock_camera()

	# teleporta o player até o Marker3D Spawn
	player_ref.global_position = spawn_point.global_position
	player_ref.global_rotation = spawn_point.global_rotation

	if loading_panel:
		await loading_panel.start_loading("")

	_hide_mouse_and_unlock_camera()

func _show_mouse_and_lock_camera():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera_travada = true
	emit_signal("camera_locked", true)

func _hide_mouse_and_unlock_camera():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_travada = false
	emit_signal("camera_locked", false)
