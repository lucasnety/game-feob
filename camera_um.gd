extends Node3D

@export var sensitivity: float = 0.2
@export var acceleration: float = 10.0
@export var distancia_max: float = 20.0  # até onde quero que a mira detecte NPCs

const MIN: float = -300.0
const MAX: float = 250.0

var cam_hor: float = 0.0
var cam_ver: float = 0.0
var mira: Control       # o Control da mira que eu coloquei na tela
var cam: Camera3D       # a câmera real do jogador
var camera_ativa: bool = true  # controla se a rotação está ativa
var inventario_aberto: bool = false  # sincroniza com o inventário

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mira = $"../CanvasLayer/Control"
	cam = $horizontal/vertical/SpringArm3D/Camera3D

	# Conecta sinal do jogador para saber quando o inventário abre ou fecha
	var player = get_parent()
	if player.has_signal("toggle_inventory"):
		player.connect("toggle_inventory", Callable(self, "_on_toggle_inventory"))


func _on_toggle_inventory() -> void:
	# Alterna o estado do inventário
	inventario_aberto = !inventario_aberto
	camera_ativa = not inventario_aberto

	if camera_ativa:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	# Alternar com ESC (ui_cancel)
	if Input.is_action_just_pressed("ui_cancel"):
		camera_ativa = !camera_ativa
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if camera_ativa else Input.MOUSE_MODE_VISIBLE)
		return

	# Se a câmera estiver desativada (inventário ou ESC), ignora movimento
	if not camera_ativa:
		return

	# Movimento da câmera
	if event is InputEventMouseMotion:
		cam_hor -= event.relative.x * sensitivity
		cam_ver = clamp(cam_ver - event.relative.y * sensitivity, -90.0, 90.0)


func _physics_process(delta: float) -> void:
	# Atualiza suavemente a rotação
	cam_ver = clamp(cam_ver, MIN, MAX)
	$horizontal.rotation_degrees.y = lerp($horizontal.rotation_degrees.y, cam_hor, acceleration * delta)
	$horizontal/vertical.rotation_degrees.x = lerp($horizontal/vertical.rotation_degrees.x, cam_ver, acceleration * delta)

	# Segurança
	if mira == null or cam == null:
		return

	var mirando_npc: bool = false
	var collider: Node = null
	
	var mira_pos: Vector2 = mira.global_position
	var ray_origin: Vector3 = cam.project_ray_origin(mira_pos)
	var ray_dir: Vector3 = cam.project_ray_normal(mira_pos)
	var ray_to: Vector3 = ray_origin + ray_dir * distancia_max

	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_to
	params.exclude = []
	params.collision_mask = 1

	var result = get_world_3d().direct_space_state.intersect_ray(params)

	if result and result.has("collider"):
		collider = result["collider"]
		if collider and collider.is_in_group("npc"):
			mirando_npc = true

	# Atualiza mira visualmente
	if mirando_npc:
		mira.color = Color(0, 1, 0)
		mira.custom_minimum_size = Vector2(30, 30)
	else:
		mira.color = Color.WHITE
		mira.custom_minimum_size = Vector2(20, 20)
	mira.queue_redraw()

	# Reseta outlines
	for npc in get_tree().get_nodes_in_group("npc"):
		var mesh = npc.get_node_or_null("MeshInstance3D")
		if mesh:
			var mat = mesh.get_active_material(0)
			if mat:
				mat.outline_enabled = false

	# Ativa outline no NPC focado
	if mirando_npc and collider:
		var mesh = collider.get_node_or_null("MeshInstance3D")
		if mesh:
			var mat = mesh.get_active_material(0)
			if mat:
				mat.outline_enabled = true
				mat.outline_color = Color(0, 1, 0)
				mat.outline_size = 0.05
