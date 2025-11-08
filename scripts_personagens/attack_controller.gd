extends Node

@onready var anim: AnimationPlayer = $"../personagem_lupus/AnimationPlayer"
@onready var sword: Node = $"../personagem_lupus/Skeleton3D/hand_attachment/Node3D"
@onready var player: Node = get_parent()
@onready var camera_ray: RayCast3D = $"../camera/horizontal/vertical/SpringArm3D/Camera3D/RayCast3D"

var is_attacking = false

func _process(_delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	is_attacking = true
	if player:
		player.is_attacking = true

	print("⛓️ Iniciando ataque...")

	if anim:
		anim.play("movimentation/ataque_um")
	else:
		push_error("⚠️ AnimationPlayer não encontrado!")

	# --- Delay até o momento do golpe (aprox. 70% da animação)
	await get_tree().create_timer(0.7).timeout

	if sword and sword.has_method("attack"):
		sword.attack()  # aplica dano no timing correto
	else:
		push_error("⚠️ Espada não encontrada ou não tem método attack().")

	# --- Espera o restante da animação (30% restante)
	await get_tree().create_timer(0.1).timeout

	is_attacking = false
	if player:
		player.is_attacking = false
	print("✅ Ataque finalizado.")
