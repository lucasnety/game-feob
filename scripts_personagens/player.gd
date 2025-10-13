extends CharacterBody3D

# Velocidades
const WALK_SPEED: float = 5.0
const RUN_SPEED: float = 10.0
const JUMP_VELOCITY: float = 4.5

# Nós
@onready var animator = $personagem_lupus/AnimationPlayer
@onready var camera_horizontal = $camera/horizontal

# Flag de pulo
var is_jumping: bool = false

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Input de pulo (Space / ação "jump")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		animator.play("movimentation/pular")

	# Rotação horizontal da câmera
	var horizontal_rotation: float = camera_horizontal.global_transform.basis.get_euler().y

	# Input do jogador usando WSAD
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = Vector3(input_dir.x, 0.0, input_dir.y)
	direction = Basis(Vector3.UP, horizontal_rotation) * direction
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO

	# Define velocidade (Shift para correr rápido)
	var current_speed: float = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = RUN_SPEED

	# Movimento do personagem
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		$personagem_lupus.rotation.y = lerp_angle($personagem_lupus.rotation.y, atan2(direction.x, direction.z), delta * 5)
		
		# Animação andar ou correr
		if not is_jumping:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_rapido")
			else:
				animator.play("movimentation/andar")
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)
		
		# Parado
		if not is_jumping and is_on_floor():
			animator.play("movimentation/parado")

	# Mantém animação de pulo enquanto no ar
	if is_jumping and not is_on_floor():
		if animator.current_animation != "movimentation/pular":
			animator.play("movimentation/pular")

	# Resetar flag de pulo ao tocar o chão
	if is_on_floor() and is_jumping:
		is_jumping = false
		# Toca animação apropriada depois do salto
		if direction.length() > 0:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_rapido")
			else:
				animator.play("movimentation/andar")
		else:
			animator.play("movimentation/parado")

	move_and_slide()
