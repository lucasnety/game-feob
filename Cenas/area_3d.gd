extends Area3D

# Cena correta do baú
var bau_scene: PackedScene = preload("res://Cenas/Cenabau.tscn"		)

# Marker3D onde o baú vai aparecer
@onready var spawn_point = $CollisionShape3D/Marker3D

var enemy_died := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.connect("tree_exited", Callable(self, "_on_enemy_died"))

func _on_enemy_died():
	if enemy_died:
		return

	enemy_died = true

	# Instancia o baú
	var bau = bau_scene.instantiate()
	get_tree().current_scene.add_child(bau)

	# Coloca na posição do Marker3D
	bau.global_position = spawn_point.global_position
	bau.global_rotation = spawn_point.global_rotation
