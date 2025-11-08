extends CharacterBody3D

@export var max_hp: int = 200
var hp: int
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer

@export var damage_number_scene: PackedScene

func _ready():
	hp = max_hp
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)

func take_damage(amount: int, crit: bool = false):
	hp -= amount
	_flash_red()
	_show_damage_number(amount, crit)
	if hp <= 0:
		_die()

func _flash_red():
	mesh.material_override.albedo_color = Color(1, 0, 0)
	timer.start()

func _on_Timer_timeout():
	mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)

func _die():
	queue_free()

func _show_damage_number(amount: int, crit: bool = false) -> void:
	if not damage_number_scene:
		return
	var dmg_label: Node3D = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg_label)
	dmg_label.global_position = global_position + Vector3(0, 3.5, 0)

	# 🔹 Chama setup imediatamente após instanciar
	dmg_label.call("setup", amount, crit)
