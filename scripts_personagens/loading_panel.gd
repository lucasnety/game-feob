extends Panel

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready():
	visible = false
	progress_bar.value = 0


func start_loading(scene_path: String):
	visible = true
	progress_bar.value = 0

	# Mostra uma barra de progresso "fake" por 1 segundo (enquanto carrega)
	for i in range(0, 100):
		progress_bar.value = i
		await get_tree().create_timer(0.01).timeout

	# Agora carrega a cena real
	var scene_res = ResourceLoader.load(scene_path)
	if scene_res:
		get_tree().change_scene_to_packed(scene_res)
	else:
		push_error("Falha ao carregar a cena: " + scene_path)

	visible = false
