extends Node3D  # ou CharacterBody3D se precisar de física

@export var npc_name: String = "Ferreiro"

# animação
@onready var animator = $ferreiro/AnimationPlayer
# mesh do NPC (o MeshInstance3D real dentro do Skeleton3D)
@onready var mesh_instance: MeshInstance3D = $ferreiro/Skeleton3D/model
# material do NPC
var material: StandardMaterial3D = null

func _ready():
	# Pega o material atual do mesh e mantém a textura original
	if mesh_instance != null:
		var mesh_material = mesh_instance.get_active_material(0)
		if mesh_material is StandardMaterial3D:
			material = mesh_material
			# desliga contorno inicialmente
			material.outline_enabled = false
			material.outline_color = Color(0,1,0)
			material.outline_size = 0.15

	# adiciono o NPC ao grupo "npc" para que a câmera possa detectá-lo
	add_to_group("npc")

	# Começa com a animação de respirar
	animator.play("ferreiro/ferreiro_respirar_um")
	
	# Conecta o sinal de animação terminada para trocar para a animação de parado
	animator.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	# Quando "ferreiro_respirar_um" terminar, passa para "ferreiro_parado"
	if anim_name == "ferreiro/ferreiro_respirar_um":
		animator.play("ferreiro/ferreiro_parado")

# Função para ligar/desligar contorno, chamada da câmera
func set_outline(active: bool) -> void:
	if material != null:
		material.outline_enabled = active
