extends Control

var grabbed_slot_data: SlotData = null

@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot

func _ready() -> void:
	# Garante que o slot agarrado comece escondido
	if grabbed_slot:
		grabbed_slot.hide()
	else:
		push_warning("GrabbedSlot não encontrado! Verifique o nome do Node.")

func _physics_process(delta: float) -> void:
	# Só atualiza a posição se o Node existir e estiver visível
	if grabbed_slot and grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	if inventory_data:
		inventory_data.inventory_interact.connect(on_inventory_interact)
		if player_inventory:
			player_inventory.set_inventory_data(inventory_data)
		else:
			push_warning("PlayerInventory não encontrado! Verifique o Node.")

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	if not inventory_data:
		return

	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)

	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if not grabbed_slot:
		return

	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
