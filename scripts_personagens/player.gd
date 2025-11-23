extends CharacterBody3D

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

# --- VIDA ---
@export var max_hp: int = 100
var hp: int
@onready var health_bar = $barra/barra_de_vida

# --- Regeneração ---
var regen_rate := 0.02  # 4% por segundo
var regen_timer := 0.0

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
@onready var ray_cast_3d: RayCast3D = $camera/horizontal/vertical/SpringArm3D/Camera3D/RayCast3D
@onready var shop_audio_1: AudioStreamPlayer3D = $ShopGreetingAudio
@onready var shop_audio_2: AudioStreamPlayer3D = $ShopGreetingAudio2
@onready var shop_audio_3: AudioStreamPlayer3D = $ShopGreetingAudio3

# --- Flags ---
var is_jumping: bool = false
var camera_travada: bool = false
var modo_combate: bool = false
var is_attacking: bool = false
var loja_aberta: bool = false


func _ready():
	randomize()
	PlayerManager.player = self
	hp = max_hp

	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = max_hp

	for portal in get_tree().get_nodes_in_group("portal"):
		if portal.has_signal("camera_locked"):
			portal.camera_locked.connect(_on_camera_locked_from_portal)

	if back_attachment: back_attachment.visible = true
	if hand_attachment: hand_attachment.visible = false


func _make_persistent():
	if get_tree() != null and get_parent() != null:
		get_parent().remove_child(self)
		get_tree().root.add_child(self)
		set_owner(null)


# ============================
# 💚 REGENERAÇÃO DE VIDA
# ============================
func _process(delta):
	if hp <= 0:
		return

	regen_timer += delta
	if regen_timer >= 1.0:
		regen_timer = 0.0

		var regen_amount = int(max_hp * regen_rate)
		hp += regen_amount

		if hp > max_hp:
			hp = max_hp

		if health_bar:
			health_bar.value = hp


func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("alterar_modo") and not camera_travada:
		modo_combate = !modo_combate
		if modo_combate:
			back_attachment.visible = false
			hand_attachment.visible = true
		else:
			back_attachment.visible = true
			hand_attachment.visible = false

	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		camera_travada = !camera_travada
		emit_signal("camera_locked", camera_travada)

	if camera_travada:
		return

	if Input.is_action_just_pressed("interact"):
		interact()

	var input_dir: Vector2 = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction: Vector3 = Vector3(input_dir.x,0,input_dir.y)

	var horizontal_rotation: float = camera_horizontal.global_transform.basis.get_euler().y
	direction = Basis(Vector3.UP, horizontal_rotation) * direction
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO

	var current_speed = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = RUN_SPEED

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if modo_combate:
		var camera_yaw = camera_horizontal.global_transform.basis.get_euler().y
		$personagem_lupus.rotation.y = lerp_angle($personagem_lupus.rotation.y, camera_yaw + PI, delta * 10)
	else:
		if direction != Vector3.ZERO:
			$personagem_lupus.rotation.y = lerp_angle($personagem_lupus.rotation.y, atan2(direction.x, direction.z), delta * 5)

	move_and_slide()

	if is_attacking:
		return

	if modo_combate:
		if is_jumping:
			animator.play("movimentation/jump_espada",0.2)
			if is_on_floor(): is_jumping = false

		elif direction.length() > 0:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_espada",0.2)
			else:
				animator.play("movimentation/andar_espada",0.2)
		else:
			animator.play("movimentation/parado_sword",0.2)

	else:
		if is_jumping:
			animator.play("movimentation/pular",0.2)
			if is_on_floor(): is_jumping = false

		elif direction.length() > 0:
			if current_speed == RUN_SPEED:
				animator.play("movimentation/correr_rapido",0.2)
			else:
				animator.play("movimentation/andar",0.2)
		else:
			animator.play("movimentation/parado",0.2)


func _on_camera_locked_from_portal(is_locked: bool) -> void:
	camera_travada = is_locked


func interact() -> void:
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()

		if not loja_aberta:
			loja_aberta = true
			var audios = [shop_audio_1, shop_audio_2, shop_audio_3]
			var chosen = audios[randi() % audios.size()]
			if not chosen.playing:
				chosen.play()
		else:
			loja_aberta = false

		if collider.has_method("player_interact"):
			collider.player_interact()


# ============================
# ⚠️ PLAYER TOMA DANO AQUI
# ============================
func take_damage(amount: int, crit := false):
	hp -= amount
	if hp < 0: hp = 0

	if health_bar:
		health_bar.value = hp

	if hp <= 0:
		die()


# ============================
# ⚰️ MORTE + REVIVER
# ============================
func die():
	animator.play("movimentation/morrer")
	await get_tree().create_timer(2).timeout
	reviver()


func reviver():
	var spawn := get_tree().current_scene.get_node("reviver")

	if spawn:
		global_transform.origin = spawn.global_transform.origin
		hp = max_hp
		if health_bar:
			health_bar.value = max_hp
	else:
		print("❌ ERRO: Nó 'reviver' não encontrado!")
