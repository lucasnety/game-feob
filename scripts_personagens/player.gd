extends CharacterBody3D

@export var inventory_data: InventoryData

# Sinais
signal toggle_inventory()
signal camera_locked(is_locked: bool)  # trava/destrava câmera

# Velocidades
const WALK_SPEED: float = 5.0
const RUN_SPEED: float = 12.0
const JUMP_VELOCITY: float = 4.5

# Nós
@onready var animator = $personagem_lupus/AnimationPlayer
@onready var camera_horizontal = $camera/horizontal

# Flags
var is_jumping: bool = false
var camera_travada: bool = false  # bloqueia câmera ao abrir inventário
var is_persistent: bool = false   # garante persistência do player entre cenas

func _ready():
	# 🔹 Registra o player globalmente
	PlayerManager.player = self

	# 🔹 Mantém o player entre cenas (não é destruído ao trocar de mapa)
	if not is_persistent:
		is_persistent = true
		get_parent().remove_child(self)
		get_tree().root.add_child(self)
		set_owner(null)  # evita erro de ownership entre cenas

	

func _physics_process(delta: float) -> void:
	# --- Inventário ---
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		camera_travada = !camera_travada
		emit_signal("camera_locked", camera_travada)

	if camera_travada:
		return  # bloqueia movimento se a câmera estiver travada

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

	# --- Rotação do personagem ---
	if direction != Vector3.ZERO:
		$personagem_lupus.rotation.y = lerp_angle(
			$personagem_lupus.rotation.y,
			atan2(direction.x, direction.z),
			delta * 5
		)

	# --- Move o personagem ---
	move_and_slide()

	# --- Lógica de animação ---
	if is_jumping:
		animator.play("movimentation/pular")
		if is_on_floor():
			is_jumping = false  # reset flag ao tocar o chão
	elif direction.length() > 0:
		if current_speed == RUN_SPEED:
			animator.play("movimentation/correr_rapido")
		else:
			animator.play("movimentation/andar")
	else:
		animator.play("movimentation/parado")
