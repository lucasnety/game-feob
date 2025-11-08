extends CharacterBody3D

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

# --- Sinais ---
signal toggle_inventory()
signal camera_locked(is_locked: bool)

# --- Velocidades ---
const WALK_SPEED: float = 5.0
const RUN_SPEED: float = 12.0
const JUMP_VELOCITY: float = 4.5

# --- Nós ---
@onready var animator = $personagem_lupus/AnimationPlayer
@onready var camera_horizontal = $camera/horizontal
@onready var hand_attachment = $personagem_lupus/Skeleton3D/hand_attachment
@onready var back_attachment = $personagem_lupus/Skeleton3D/back_attachment

# --- Flags ---
var is_jumping: bool = false
var camera_travada: bool = false
var modo_combate: bool = false
var is_attacking: bool = false  # 🔹 nova flag — indica quando o personagem está atacando

func _ready():
	# 🔹 Registra globalmente
	PlayerManager.player = self

	# 🔹 Conecta automaticamente ao portal (qualquer um na cena)
	var portals = get_tree().get_nodes_in_group("portal")
	for portal in portals:
		if portal.has_signal("camera_locked"):
			portal.camera_locked.connect(_on_camera_locked_from_portal)

	# 🔹 Espada começa nas costas
	if back_attachment:
		back_attachment.visible = true
	if hand_attachment:
		hand_attachment.visible = false


func _make_persistent():
	if get_tree() != null and get_parent() != null:
		get_parent().remove_child(self)
		get_tree().root.add_child(self)
		set_owner(null)


func _physics_process(delta: float) -> void:
	# --- Alternar modo de combate (TAB) ---
	if Input.is_action_just_pressed("alterar_modo") and not camera_travada:
		modo_combate = !modo_combate

		if modo_combate:
			if back_attachment:
				back_attachment.visible = false
			if hand_attachment:
				hand_attachment.visible = true
		else:
			if back_attachment:
				back_attachment.visible = true
			if hand_attachment:
				hand_attachment.visible = false

	# --- Inventário ---
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		camera_travada = !camera_travada
		emit_signal("camera_locked", camera_travada)

	if camera_travada:
		return

	# --- Input de movimento ---
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = Vector3(input_dir.x, 0.0, input_dir.y)
	var horizontal_rotation: float = camera_horizontal.global_transform.basis.get_euler().y
	direction = Basis(Vector3.UP, horizontal_rotation) * direction
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO

	# --- Velocidade ---
	var current_speed: float = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = RUN_SPEED

	# --- Gravidade ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Pulo ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# --- Movimento horizontal ---
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# --- Rotação ---
	if direction != Vector3.ZERO:
		$personagem_lupus.rotation.y = lerp_angle(
			$personagem_lupus.rotation.y,
			atan2(direction.x, direction.z),
			delta * 5
		)

	# --- Move ---
	move_and_slide()

	# --- ⛔ Bloqueia outras animações se estiver atacando ---
	if is_attacking:
		return  # não muda animação durante o ataque

	# --- Animações (suavizadas com blend_time 0.2) ---
	if modo_combate:
		if is_jumping:
			animator.play("movimentation/jump_espada", 0.2)
			if is_on_floor():
				is_jumping = false
		elif direction.length() > 0:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_espada", 0.2)
			else:
				animator.play("movimentation/andar_espada", 0.2)
		else:
			animator.play("movimentation/parado_sword", 0.2)
	else:
		if is_jumping:
			animator.play("movimentation/pular", 0.2)
			if is_on_floor():
				is_jumping = false
		elif direction.length() > 0:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_rapido", 0.2)
			else:
				animator.play("movimentation/andar", 0.2)
		else:
			animator.play("movimentation/parado", 0.2)


# --- Função chamada quando o portal trava ou destrava a câmera ---
func _on_camera_locked_from_portal(is_locked: bool) -> void:
	camera_travada = is_locked
