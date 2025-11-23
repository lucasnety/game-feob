extends Node3D

signal camera_locked(is_locked: bool)

@onready var area = $Area3D
@onready var label_m = $CanvasLayer/Label
@onready var menu = $CanvasLayer/Panel
@onready var loading_panel = $CanvasLayer/LoadingPanel

@onready var Maker_Normal: Marker3D = $"../../Maker_Normal"
@onready var Maker_Cruel: Marker3D = $"../../Maker_Cruel"
@onready var Maker_Infernal: Marker3D = $"../../Maker_Infernal"

var player_dentro = false
var player_ref: CharacterBody3D = null
var camera_travada: bool = false

func _ready():
	label_m.visible = false
	if menu:
		menu.visible = false
	if loading_panel:
		loading_panel.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	call_deferred("_init_buttons")

func _init_buttons():
	if not menu:
		return

	menu.get_node("VBoxContainer/ButtonNormal").pressed.connect(Callable(self, "_on_dificulty_selected").bind("Normal"))
	menu.get_node("VBoxContainer/ButtonCruel").pressed.connect(Callable(self, "_on_dificulty_selected").bind("Cruel"))
	menu.get_node("VBoxContainer/ButtonInfernal").pressed.connect(Callable(self, "_on_dificulty_selected").bind("Infernal"))
	menu.get_node("VBoxContainer/ButtonVoltar").pressed.connect(_on_voltar_pressed)

func _on_body_entered(body):
	if body.name == "Player":
		player_dentro = true
		player_ref = body
		label_m.visible = true

		# Conecta o sinal do portal à câmera do player
		var camera_node = player_ref.get_node_or_null("camera")
		if camera_node and not is_connected("camera_locked", Callable(camera_node, "_on_portal_camera_locked")):
			connect("camera_locked", Callable(camera_node, "_on_portal_camera_locked"))

func _on_body_exited(body):
	if body.name == "Player":
		player_dentro = false
		label_m.visible = false
		if menu:
			menu.visible = false
		_hide_mouse_and_unlock_camera()

func _process(delta):
	if player_dentro and Input.is_action_just_pressed("interact"):
		if menu:
			menu.visible = true
		label_m.visible = false
		_show_mouse_and_lock_camera()

func _show_mouse_and_lock_camera():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera_travada = true
	emit_signal("camera_locked", true)

func _hide_mouse_and_unlock_camera():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_travada = false
	emit_signal("camera_locked", false)

func _on_dificulty_selected(level):
	print("Dificuldade escolhida:", level)
	if menu:
		menu.visible = false

	_hide_mouse_and_unlock_camera()
	GameState.dificuldade = level

	if player_ref:
		# Esconde a barra de vida durante o loading
		var health_bar = player_ref.get_node_or_null("barra/barra_de_vida")
		if health_bar:
			health_bar.visible = false

		match level:
			"Normal": if Maker_Normal: player_ref.global_transform = Maker_Normal.global_transform
			"Cruel": if Maker_Cruel: player_ref.global_transform = Maker_Cruel.global_transform
			"Infernal": if Maker_Infernal: player_ref.global_transform = Maker_Infernal.global_transform

		if loading_panel:
			await loading_panel.start_loading("")

		# Mostra a barra de vida de volta
		if health_bar:
			health_bar.visible = true

func _on_voltar_pressed():
	if menu:
		menu.visible = false
	if player_dentro:
		label_m.visible = true
	_hide_mouse_and_unlock_camera()
