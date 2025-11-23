extends Node3D

@export var damage: int = 25
@export var crit_chance: float = 0.2  # 20% de chance
@export var crit_multiplier: float = 2.0  # Dano crítico = 2x

@onready var area: Area3D = $Espada_lobo/Area3D

var owner_body: Node = null  # 👈 Dono da espada

func _ready():
	if area:
		area.monitoring = false
		area.body_entered.connect(_on_body_entered)
	else:
		push_error("⚠️ Area3D não encontrada!")

	# Se a espada estiver dentro do Player (o pai dela)
	owner_body = get_parent()


func attack(direction: Vector3 = Vector3.FORWARD):
	print("🗡️ Espada atacando:", name, " | Direção:", direction)

	if area == null:
		push_error("⚠️ Area3D não encontrada!")
		return

	area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	area.monitoring = false

	print("💤 Ataque encerrado")


func _on_body_entered(body):
	# ❌ Evita acertar o próprio dono
	if body == owner_body:
		print("⛔ Ignorado — dono da espada:", body.name)
		return

	# ❌ Evita acertar jogadores
	if body.is_in_group("player"):
		print("⛔ Ignorado — PLAYER:", body.name)
		return

	# ❌ Evita acertar coisas sem life
	if not body.has_method("take_damage"):
		print("⛔ Ignorado — não possui take_damage():", body.name)
		return

	# --- Cálculo do dano ---
	var final_damage = damage
	var is_crit = false

	if randf() <= crit_chance:
		final_damage *= crit_multiplier
		is_crit = true

	# Aplica dano
	body.take_damage(final_damage, is_crit)

	if is_crit:
		print("💥 CRÍTICO em:", body.name, "| Dano:", final_damage)
	else:
		print("💥 Acertou:", body.name, "| Dano:", final_damage)
