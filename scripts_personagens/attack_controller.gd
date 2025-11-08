extends Node

@onready var anim: AnimationPlayer = $"../personagem_lupus/AnimationPlayer"
@onready var sword: Node = $"../personagem_lupus/Skeleton3D/hand_attachment/Node3D"
@onready var player: Node = get_parent()  # 🔹 referencia direta ao Player

var is_attacking = false

func _process(_delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	is_attacking = true
	if player:
		player.is_attacking = true  # 🔹 trava animações do Player

	print("⛓️ Iniciando ataque...")

	# --- Toca a animação do personagem ---
	if anim:
		anim.play("movimentation/ataque_um")
	else:
		push_error("⚠️ AnimationPlayer não encontrado!")

	# --- Delay antes de aplicar o dano (para coincidir com o golpe) ---
	await get_tree().create_timer(0.15).timeout

	if sword and sword.has_method("attack"):
		sword.attack()
	else:
		push_error("⚠️ Espada não encontrada ou não tem método attack()!")

	# --- Espera o fim da animação de ataque (ajuste o tempo se necessário) ---
	await get_tree().create_timer(0.6).timeout

	is_attacking = false
	if player:
		player.is_attacking = false  # 🔹 libera o controle do Player
	print("✅ Ataque finalizado.")
