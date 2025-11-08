extends Node3D

@export var damage: int = 25
@export var crit_chance: float = 0.2  # 20% de chance
@export var crit_multiplier: float = 2.0  # Dano crítico = 2x

@onready var area: Area3D = $Espada_lobo/Area3D

func _ready():
	if area:
		area.monitoring = false
		area.body_entered.connect(_on_body_entered)
	else:
		push_error("⚠️ Area3D não encontrada!")

# 🔹 Agora attack recebe a direção do ataque
func attack(direction: Vector3 = Vector3.FORWARD):
	print("🗡️ Espada atacando:", name, " | Direção:", direction)

	if area == null:
		push_error("⚠️ Area3D não encontrada!")
		return

	# 🔹 Ativa hitbox temporariamente
	area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	area.monitoring = false

	print("💤 Ataque encerrado")

func _on_body_entered(body):
	if body.has_method("take_damage"):
		var final_damage = damage
		var is_crit = false

		# 🔹 Checa chance crítica
		if randf() <= crit_chance:
			final_damage *= crit_multiplier
			is_crit = true

		# 🔹 Passa o flag de crítico corretamente
		body.take_damage(final_damage, is_crit)

		if is_crit:
			print("💥 Acertou CRÍTICO:", body.name, "| Dano:", final_damage)
		else:
			print("💥 Acertou:", body.name, "| Dano:", final_damage)
