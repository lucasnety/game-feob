extends CharacterBody3D

@export var max_hp: int = 100
var hp: int
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer

func _ready():
	hp = max_hp
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8) # cor normal
	print("Cilindro ativo em:", global_position)

func take_damage(amount: int):
	hp -= amount
	print("Cilindro tomou dano! HP:", hp)
	_flash_red()
	if hp <= 0:
		_die()

func _flash_red():
	mesh.material_override.albedo_color = Color(1, 0, 0)
	timer.start()

func _on_Timer_timeout():
	mesh.material_override.albedo_color = Color(0.2, 0.8, 0.8)

func _die():
	print("Cilindro destruído!")
	queue_free()
