extends Node3D

# --- Referências ---
@onready var area = $Area3D
@onready var label_m = $CanvasLayer/Label
@onready var menu = $CanvasLayer/Panel
@onready var loading_panel = $CanvasLayer/LoadingPanel

@onready var Maker_Normal: Marker3D = $"../../Maker_Normal"
@onready var Maker_Cruel: Marker3D = $"../../Maker_Cruel"
@onready var Maker_Infernal: Marker3D = $"../../Maker_Infernal"

# --- Variáveis ---
var player_dentro = false
var player_ref: CharacterBody3D = null

func _ready():
	label_m.visible = false
	if menu:
		menu.visible = false
	if loading_panel:
		loading_panel.visible = false

	# Conecta sinais do Area3D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	# Inicializa botões do menu
	call_deferred("_init_buttons")


func _init_buttons():
	if not menu:
		return

	var btn_normal = menu.get_node_or_null("VBoxContainer/ButtonNormal")
	if btn_normal:
		btn_normal.pressed.connect(Callable(self, "_on_dificulty_selected").bind("Normal"))

	var btn_cruel = menu.get_node_or_null("VBoxContainer/ButtonCruel")
	if btn_cruel:
		btn_cruel.pressed.connect(Callable(self, "_on_dificulty_selected").bind("Cruel"))

	var btn_infernal = menu.get_node_or_null("VBoxContainer/ButtonInfernal")
	if btn_infernal:
		btn_infernal.pressed.connect(Callable(self, "_on_dificulty_selected").bind("Infernal"))

	var btn_voltar = menu.get_node_or_null("VBoxContainer/ButtonVoltar")
	if btn_voltar:
		btn_voltar.pressed.connect(Callable(self, "_on_voltar_pressed"))


# Detecta quando o player entra na Area3D
func _on_body_entered(body):
	if body.name == "Player":
		player_dentro = true
		player_ref = body
		label_m.visible = true

# Detecta quando o player sai da Area3D
func _on_body_exited(body):
	if body.name == "Player":
		player_dentro = false
		label_m.visible = false
		if menu:
			menu.visible = false

func _process(delta):
	if player_dentro and Input.is_action_just_pressed("interact"):
		if menu:
			menu.visible = true
		label_m.visible = false

# Botões de dificuldade
func _on_dificulty_selected(level):
	print("Dificuldade escolhida:", level)
	if menu:
		menu.visible = false

	GameState.dificuldade = level

	# Teleporte para o Maker correspondente
	if player_ref != null:
		match level:
			"Normal":
				if Maker_Normal != null:
					player_ref.global_transform = Maker_Normal.global_transform
			"Cruel":
				if Maker_Cruel != null:
					player_ref.global_transform = Maker_Cruel.global_transform
			"Infernal":
				if Maker_Infernal != null:
					player_ref.global_transform = Maker_Infernal.global_transform

	if loading_panel:
		await loading_panel.start_loading("")  # apenas efeito visual


func _on_voltar_pressed():
	if menu:
		menu.visible = false
	if player_dentro:
		label_m.visible = true
