extends Control

var tempo: float = 0.0

func _ready():
	$TextureRect/LoadingBar.value = 0
	set_process(true)

func _process(delta):
	tempo += delta
	
	# Anima a barra de 0 a 100 em 2 segundos
	$TextureRect/LoadingBar.value = lerp(0.0, 100.0, tempo / 2.0)
	
	# Atualiza o texto
	$TextureRect/LoadingText.text = "Carregando... " + str(int($TextureRect/LoadingBar.value)) + "%"
	
	# Quando acabar, troca pra cena
	if $TextureRect/LoadingBar.value >= 100.0:
		var cidade = load("res://Cenas/cidade.tscn")
		get_tree().change_scene_to_packed(cidade)
