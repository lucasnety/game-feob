extends Node3D

# --- Referências ---
@onready var spawn: Marker3D = $Spawn
@onready var inventory_interface: Control = $UI/InventoryInterface

# --- Variáveis ---
var player_scene: PackedScene = preload("res://Cenas/Player.tscn")
var player_node: Node3D = null
var player: CharacterBody3D = null

func _ready() -> void:
	# 1️⃣ Instancia Player
	player_node = player_scene.instantiate() as Node3D
	if player_node == null:
		push_error("Falha ao instanciar Player.tscn!")
		return

	# 2️⃣ Adiciona à cena principal antes de qualquer lógica interna
	add_child(player_node)

	# 3️⃣ Posiciona no Spawn
	player_node.global_transform = spawn.global_transform

	# 4️⃣ Pega CharacterBody3D
	player = player_node.get_node_or_null("CharacterBody3D") as CharacterBody3D
	if player == null:
		push_error("Não encontrou CharacterBody3D dentro do Player.tscn")
		return

	# 5️⃣ Conecta inventário
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)

	# 6️⃣ Marca o Player como persistente **após ele estar na árvore**
	player.call_deferred("_make_persistent")


func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
