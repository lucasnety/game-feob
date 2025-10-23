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



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# pego a mira na tela
	mira = $"../CanvasLayer/Control"
	# pego a câmera certa para calcular o raycast
	cam = $horizontal/vertical/SpringArm3D/Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_hor -= event.relative.x * sensitivity
		cam_ver = clamp(cam_ver - event.relative.y * sensitivity, -90.0, 90.0)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# faço a rotação da câmera com lerp para ficar suave
	cam_ver = clamp(cam_ver, MIN, MAX)
	$horizontal.rotation_degrees.y = lerp($horizontal.rotation_degrees.y, cam_hor, acceleration * delta)
	$horizontal/vertical.rotation_degrees.x = lerp($horizontal/vertical.rotation_degrees.x, cam_ver, acceleration * delta)

	# começo a ver se estou mirando em algum NPC
	if mira == null or cam == null:
		return

	var mirando_npc: bool = false
	var collider: Node = null
	
	# pego a posição do centro da mira na tela
	var mira_pos: Vector2 = mira.global_position
	
	# calculo a origem e direção do ray a partir da câmera
	var ray_origin: Vector3 = cam.project_ray_origin(mira_pos)
	var ray_dir: Vector3 = cam.project_ray_normal(mira_pos)
	var ray_to: Vector3 = ray_origin + ray_dir * distancia_max

	# crio os parâmetros do raycast
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_to
	params.exclude = []           # aqui poderia colocar o player pra não se detectar
	params.collision_mask = 1     # só quero detectar os NPCs

	# faço o raycast
	var result = get_world_3d().direct_space_state.intersect_ray(params)

	# verifico se bateu em algum NPC
	if result != null and result.has("collider"):
		collider = result["collider"]
		if collider != null and collider.is_in_group("npc"):
			mirando_npc = true

	# atualizo a cor da mira e tamanho
	if mirando_npc:
		mira.color = Color(0,1,0)  # verde quando estiver mirando no NPC
		mira.custom_minimum_size = Vector2(30, 30)  # aumenta a mira pra destacar
	else:
		mira.color = Color.WHITE   # volta para branco caso contrário
		mira.custom_minimum_size = Vector2(20, 20)  # tamanho normal da mira
	mira.queue_redraw()

	# agora aplico contorno no NPC via código
	# primeiro desligo contorno de todos NPCs
	for npc in get_tree().get_nodes_in_group("npc"):
		var mesh = npc.get_node_or_null("MeshInstance3D")
		if mesh != null:
			var mat = mesh.get_active_material(0)
			if mat != null:
				mat.outline_enabled = false

	# se estiver mirando em um NPC, ativo contorno nele
	if mirando_npc and collider != null:
		var mesh = collider.get_node_or_null("MeshInstance3D")
		if mesh != null:
			var mat = mesh.get_active_material(0)
			if mat != null:
				mat.outline_enabled = true
				mat.outline_color = Color(0,1,0)  # verde
				mat.outline_size = 0.05
