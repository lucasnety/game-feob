extends Node3D

@export var float_speed: float = 1.0  # Velocidade de subida do número
@export var lifetime: float = 1.0     # Tempo de vida do número em segundos

var elapsed := 0.0
@onready var label: Label3D = $Label3D

# 🔹 Função para inicializar o dano e se é crítico
func setup(amount: int, crit: bool = false) -> void:
	label.text = str(amount)
	if crit:
		label.modulate = Color(1, 1, 0)  # Amarelo para crítico
		label.scale = Vector3(1.5, 1.5, 1.5)  # Número crítico maior
	else:
		label.modulate = Color(1, 1, 1)      # Branco normal
		label.scale = Vector3(1, 1, 1)      # Tamanho normal

func _ready():
	# Pequenas variações visuais para evitar que todos fiquem idênticos
	rotation.y = randf_range(-0.3, 0.3)
	scale *= randf_range(0.9, 1.1)

func _process(delta: float) -> void:
	# 🔹 Faz o texto olhar para a câmera ativa
	var camera := get_viewport().get_camera_3d()
	if camera:
		look_at(camera.global_position, Vector3.UP)
		rotate_y(PI)  # Corrige inversão do Label3D

	# 🔹 Faz o número subir
	global_position.y += float_speed * delta

	# 🔹 Controle de transparência para desaparecer gradualmente
	elapsed += delta
	label.modulate.a = 1.0 - (elapsed / lifetime)

	if elapsed >= lifetime:
		queue_free()
