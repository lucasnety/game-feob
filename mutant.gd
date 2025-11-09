extends CharacterBody3D

# ======= Atributos =======
@export var speed := 3.0
@export var attack_range := 2.0
@export var attack_damage := 10
@export var attack_cooldown := 2.0
@export var max_hp := 50
var hp := max_hp

# ======= Nós =======
@onready var mutant = $'mutantrex'
var animator: AnimationPlayer = null
@onready var attack_area = $AttackArea
@onready var mesh: MeshInstance3D = null
@onready var timer: Timer = $Timer

@export var damage_number_scene: PackedScene

# ======= Variáveis =======
var player: Node3D = null
var can_attack := true

func _ready():
	# Pega referências dentro do mutantrex
	if mutant:
		animator = mutant.get_node_or_null("AnimationPlayer")
		mesh = mutant.get_node_or_null("MeshInstance3D")
		if mesh:
			mesh.material_override = StandardMaterial3D.new()
			mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)

	# Toca animação parado inicialmente
	if animator and animator.has_animation("mutante/mutante_parado"):
		animator.play("mutante/mutante_parado", 0.2)

func _physics_process(delta):
	if hp <= 0:
		die()
		return

	# Tenta encontrar o player a cada frame se ainda não encontrou
	if not player:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0]
		else:
			# Se não encontrou o player, fica parado
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			if animator and animator.has_animation("mutante/mutante_parado"):
				animator.play("mutante/mutante_parado", 0.2)
			return

	# --- Distância para o player ---
	var direction = (player.global_position - global_position)
	var distance = direction.length()
	direction.y = 0
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO

	# --- Decide ação ---
	if distance > attack_range:
		# Seguir player
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		move_and_slide()

		# Rotaciona suavemente para o player
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 5)

		# Animação andar
		if animator and animator.has_animation("mutante/mutante_caminhar"):
			animator.play("mutante/mutante_caminhar", 0.2)
	else:
		# Atacar
		velocity.x = 0
		velocity.z = 0
		move_and_slide()

		# Rotaciona para o player
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 10)

		attack_player()

# ======= Ataque =======
func attack_player():
	if can_attack:
		can_attack = false
		var choice = randi() % 3
		match choice:
			0:
				if animator and animator.has_animation("mutante/mutante_soco"):
					animator.play("mutante/mutante_soco", 0.2)
			1:
				if animator and animator.has_animation("mutante/mutante_socoforte"):
					animator.play("mutante/mutante_socoforte", 0.2)
			2:
				if animator and animator.has_animation("mutante/mutante_jumpattack"):
					animator.play("mutante/mutante_jumpattack", 0.2)

		# Aplica dano imediatamente (pode melhorar sincronizando com a animação depois)
		if player and player.has_method("take_damage"):
			var damage = attack_damage
			if choice == 1:
				damage *= 2
			elif choice == 2:
				damage += 5
			player.take_damage(damage)

		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

# ======= Receber dano =======
func take_damage(amount: int, crit: bool=false):
	hp -= amount
	flash_red()
	show_damage_number(amount, crit)
	if hp <= 0:
		die()
	else:
		# Se estiver parado, volta animação parado
		if animator and animator.has_animation("mutante/mutante_parado"):
			animator.play("mutante/mutante_parado", 0.2)

func flash_red():
	if mesh:
		mesh.material_override.albedo_color = Color(1,0,0)
		timer.start()

func _on_Timer_timeout():
	if mesh:
		mesh.material_override.albedo_color = Color(0.2,0.8,0.8)

func show_damage_number(amount: int, crit: bool=false):
	if not damage_number_scene:
		return
	var dmg_label = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg_label)
	dmg_label.global_position = global_position + Vector3(0,3.5,0)
	dmg_label.call("setup", amount, crit)

# ======= Morte =======
func die():
	velocity = Vector3.ZERO
	if animator and animator.has_animation("mutante/mutante_morrer"):
		animator.play("mutante/mutante_morrer", 0.2)
	queue_free()
