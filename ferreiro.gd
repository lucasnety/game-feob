extends Node3D  # ou CharacterBody3D se precisar de física

@onready var animator = $ferreiro/AnimationPlayer

func _ready():
	# Começa com a animação de respirar
	animator.play("ferreiro/ferreiro_respirar_um")
	
	# Conecta o sinal de animação terminada para trocar para a animação de parado
	animator.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	# Quando "ferreiro_respirar_um" terminar, passa para "ferreiro_parado"
	if anim_name == "ferreiro/ferreiro_respirar_um":
		animator.play("ferreiro/ferreiro_parado")
