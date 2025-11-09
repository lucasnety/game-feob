extends CharacterBody3D

@export_group("Comportamento")
@export var speed: float = 3.0
@export var attack_range: float = 5.0
@export var attack_stop_distance: float = 3
@export var attack_damage: int = 15
@export var attack_cooldown: float = 1.0

@export_group("Vida")
@export var max_hp: int = 250
@export var damage_number_height: float = 2.0

@export_group("Referências")
@export var damage_number_scene: PackedScene

var hp: int
var player: Node3D = null
var can_attack := true
var is_attacking := false
var is_taking_damage := false
var animator: AnimationPlayer = null
var mesh: MeshInstance3D = null

@onready var mutant = $mutantrex
@onready var attack_area = $AttackArea
@onready var timer: Timer = $Timer

func _ready():
	hp = max_hp
	if mutant:
		animator = mutant.get_node_or_null("AnimationPlayer")
		mesh = mutant.get_node_or_null("MeshInstance3D")
		if mesh:
			mesh.material_override = StandardMaterial3D.new()
			mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)
	play_idle()

func _physics_process(delta):
	if hp <= 0:
		die()
		return

	if not player:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0]
		else:
			play_idle()
			return

	if is_attacking or is_taking_damage:
		return

	var direction = player.global_position - global_position
	var distance = direction.length()
	direction.y = 0
	direction = direction.normalized() if direction.length() > 0 else Vector3.ZERO

	if distance > attack_stop_distance:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		move_and_slide()
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 5)
		play_animation("mutante/mutante_caminhar")
	elif distance <= attack_range:
		velocity = Vector3.ZERO
		move_and_slide()
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 10)
		attack_player()
	else:
		play_idle()

func attack_player():
	if not can_attack or is_attacking or is_taking_damage:
		return

	can_attack = false
	is_attacking = true

	var choice = randi() % 2
	var anim_name = "mutante/mutante_soco" if choice == 0 else "mutante/mutante_socoforte"
	var damage = attack_damage if choice == 0 else attack_damage * 2

	play_animation(anim_name)
	await get_tree().create_timer(0.6).timeout

	if player and player.has_method("take_damage"):
		player.take_damage(damage)

	await get_tree().create_timer(1.5).timeout
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func play_animation(anim_name: String):
	if animator and animator.has_animation(anim_name):
		if animator.current_animation != anim_name:
			animator.play(anim_name, 0.3)

func play_idle():
	if is_attacking or is_taking_damage:
		return
	if animator and animator.has_animation("mutante/mutante_parado"):
		if animator.current_animation != "mutante/mutante_parado":
			animator.play("mutante/mutante_parado", 0.3)

func take_damage(amount: int, crit: bool = false):
	if hp <= 0 or is_taking_damage:
		return

	hp -= amount
	flash_red()
	show_damage_number(amount, crit)
	is_taking_damage = true

	if animator and animator.has_animation("mutante/mutante_tomar_dano"):
		animator.play("mutante/mutante_tomar_dano", 0.3)
		var duration = animator.current_animation_length
		await get_tree().create_timer(duration).timeout

	is_taking_damage = false

	if hp <= 0:
		die()
	else:
		play_idle()

func flash_red():
	if mesh:
		mesh.material_override.albedo_color = Color(1, 0, 0)
		timer.start()

func _on_Timer_timeout():
	if mesh:
		mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)

func show_damage_number(amount: int, crit: bool = false):
	if not damage_number_scene:
		return
	var dmg_label = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg_label)
	dmg_label.global_position = global_position + Vector3(0, damage_number_height, 0)
	dmg_label.call("setup", amount, crit)

func die():
	velocity = Vector3.ZERO
	if animator and animator.has_animation("mutante/mutante_morrer"):
		animator.play("mutante/mutante_morrer", 0.3)
	await get_tree().create_timer(3.0).timeout
	queue_free()
