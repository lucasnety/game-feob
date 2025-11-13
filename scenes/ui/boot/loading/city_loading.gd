extends Control

@export var cena_cidade_path := "res://Cenas/cidade.tscn"

var tempo := 0.0

func _ready():
	$TextureProgressBar.value = 0
	set_process(true)

func _process(delta):
	tempo += delta

	$TextureProgressBar.value = lerp(0, 100, tempo / 2.0)

	# aqui agora vai ✔
	$LoadingText.text = "Carregando... " + str(int($TextureProgressBar.value)) + "%"

	if $TextureProgressBar.value >= 100:
		var cidade = load(cena_cidade_path)
		get_tree().change_scene_to_packed(cidade)
