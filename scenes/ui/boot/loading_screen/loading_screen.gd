extends Control

@onready var loading_bar = $LoadingBar
@onready var loading_text = $LoadingText

var load_progress := 0.0
var next_scene_path := "res://scenes/ui/boot/main_menu/main_menu.tscn"

func _ready():
	loading_bar.value = 0
	loading_text.text = "Carregando..."
	simulate_loading()

func simulate_loading():
	var timer = Timer.new()
	timer.wait_time = 0.1 # velocidade do carregamento
	timer.one_shot = false
	timer.timeout.connect(_on_timer_tick)
	add_child(timer)
	timer.start()

func _on_timer_tick():
	load_progress += 4
	loading_bar.value = load_progress

	if load_progress >= 100:
		loading_bar.value = 100
		loading_text.text = "Concluído!"
		get_tree().create_timer(1.0).timeout.connect(_go_to_next_scene)

func _go_to_next_scene():
	get_tree().change_scene_to_file(next_scene_path)
