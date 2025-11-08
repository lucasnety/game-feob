extends Node

@onready var anim: AnimationPlayer = $"../personagem_lupus/AnimationPlayer"
@onready var sword: Node = $"../personagem_lupus/Skeleton3D/hand_attachment/Node3D"
@onready var player: Node = get_parent() # 🔹 referência direta ao Player
@onready var camera_ray: RayCast3D = $"../camera/horizontal/vertical/SpringArm3D/Camera3D/RayCast3D"

var is_attacking = false

func _process(_delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	is_attacking = true
	if player:
		player.is_attacking = true  # 🔹 trava animações do Player

	print("⛓️ Iniciando ataque...")

	# --- Toca a animação de ataque ---
	if anim:
		anim.play("movimentation/ataque_um")
	else:
		push_error("⚠️ AnimationPlayer não encontrado!")

	# --- Espera o momento do golpe ---
	await get_tree().create_timer(0.15).timeout

	# --- Calcula a direção do ataque pelo ponto branco da câmera ---
	var attack_direction: Vector3
	if camera_ray and camera_ray.is_colliding():
		var hit_pos = camera_ray.get_collision_point()
		attack_direction = (hit_pos - sword.global_position).normalized()
		print("🎯 Direção do ataque:", attack_direction)
	else:
		attack_direction = -camera_ray.global_transform.basis.z.normalized()
		print("⚔️ Atacando para frente.")

	# --- Chama o ataque da espada enviando só a direção ---
	if sword and sword.has_method("attack"):
		sword.attack(attack_direction)
	else:
		push_error("⚠️ Espada não encontrada ou não tem método attack().")

	# --- Fim da animação ---
	await get_tree().create_timer(0.6).timeout

	is_attacking = false
	if player:
		player.is_attacking = false
	print("✅ Ataque finalizado.")
