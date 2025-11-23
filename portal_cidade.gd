extends Node3D

@onready var area = $Area3D
@onready var label_m = $CanvasLayer/Label
@onready var loading_panel = $CanvasLayer/LoadingPanel

# Caminho do maker reviver
@onready var Maker_Reviver: Marker3D = $"../../../reviver"

var player_dentro = false
var player_ref: CharacterBody3D = null

func _ready():
	label_m.visible = false
	if loading_panel:
		loading_panel.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_dentro = true
		player_ref = body
		label_m.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_dentro = false
		label_m.visible = false

func _process(delta):
	if player_dentro and Input.is_action_just_pressed("interact"):

		label_m.visible = false

		if not player_ref:
			return

		# pega a barra de vida dentro do player
		var health_bar = player_ref.get_node_or_null("barra/barra_de_vida")
		if health_bar:
			health_bar.visible = false

		# CHAMA TELINHA DE LOADING
		if loading_panel:
			await loading_panel.start_loading("")

		# TELEPORTA O PLAYER
		_teleportar_player()

		# deixa a barra de vida visível novamente
		if health_bar:
			health_bar.visible = true

func _teleportar_player():
	if not player_ref:
		print("ERRO: player_ref está null")
		return

	if not Maker_Reviver:
		print("ERRO: Maker_Reviver não encontrado no caminho '../../../reviver'")
		return

	print("Teleportando player para reviver...")
	player_ref.global_transform = Maker_Reviver.global_transform
