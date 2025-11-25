extends Control

var grabbed_slot_data: SlotData = null
var external_inventory_owner


@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot
@onready var equip_inventory: PanelContainer = $EquipInventory
@onready var moedas_label: Label = $"../MoedasLabel"
@onready var fragmentos_label: Label = $"../FragmentosLabel"
@onready var external_inventory: PanelContainer = $ExternalInventory



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
	inventory_data.inventory_updated.connect(update_moedas_display)
	update_moedas_display(inventory_data)
	inventory_data.inventory_updated.connect(update_fragmentos_display)
	update_fragmentos_display(inventory_data)

	if inventory_data:
		inventory_data.inventory_interact.connect(on_inventory_interact)
		if player_inventory:
			player_inventory.set_inventory_data(inventory_data)
		else:
			push_warning("PlayerInventory não encontrado! Verifique o Node.")


func set_equip_inventory_data(inventory_data: InventoryData) -> void:
	if inventory_data:
		inventory_data.inventory_interact.connect(on_inventory_interact)
		if equip_inventory:
			equip_inventory.set_inventory_data(inventory_data)
		else:
			push_warning("PlayerInventory não encontrado! Verifique o Node.")


func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data

	if inventory_data:
		inventory_data.inventory_interact.connect(on_inventory_interact)
		if external_inventory:
			external_inventory.set_inventory_data(inventory_data)
		else:
			push_warning("external_inventory não encontrado! Verifique o Node.")

		external_inventory.show()


func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		external_inventory.hide()
		external_inventory_owner = null


func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	if not inventory_data:
		return

	# Check if this is the external inventory
	var is_external = false
	if external_inventory_owner and external_inventory_owner.inventory_data:
		is_external = inventory_data == external_inventory_owner.inventory_data

	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			if is_external:
				var slot_data: SlotData = inventory_data.slot_datas[index]
				if slot_data and slot_data.item_data:
					if try_buy_item(slot_data):
						# Purchase successful → grab the item
						grabbed_slot_data = inventory_data.grab_slot_data(index)
					else:
						print("❌ Not enough coins to buy this item!")
						return
			else:
				# Normal inventory grab
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


func update_moedas_display(inventory_data: InventoryData) -> void:
	if is_instance_valid(moedas_label):
		var total_gold = inventory_data.get_total_moedas()
		moedas_label.text = "moedas: " + str(total_gold)

func update_fragmentos_display(inventory_data: InventoryData) -> void:
	if is_instance_valid(fragmentos_label):
		var total_fragmentos = inventory_data.get_total_fragmentos()
		fragmentos_label.text = "fragmentos de ansiedade: " + str(total_fragmentos)

func try_buy_item(slot_data: SlotData) -> bool:
	if not slot_data or not slot_data.item_data:
		return false

	# --- Determine item price safely ---
	var item_price := 0

	# Check if the item has a 'preco' or 'price' variable
	
	if "price" in slot_data.item_data:
		item_price = int(slot_data.item_data.price)

	if item_price <= 0:
		return true  # free item or price not set

	# --- Access player's inventory ---
	var player_data: InventoryData = player_inventory.inventory_data
	if not player_data:
		push_warning("⚠️ Player inventory data not found.")
		return false

	var total_coins = player_data.get_total_moedas()
	if total_coins < item_price:
		return false

	# --- Deduct coins ---
	var remaining = item_price
	for i in range(player_data.slot_datas.size()):
		var coin_slot = player_data.slot_datas[i]
		if coin_slot and coin_slot.item_data and coin_slot.item_data.nome == "moeda":
			var to_remove = min(coin_slot.quantidade, remaining)
			coin_slot.quantidade -= to_remove
			remaining -= to_remove

			if coin_slot.quantidade <= 0:
				player_data.slot_datas[i] = null

			if remaining <= 0:
				break

	# --- Update inventory and UI ---
	player_data.inventory_updated.emit(player_data)
	update_moedas_display(player_data)

	print(" Purchased", slot_data.item_data.nome, "for", item_price, "coins.")
	return true
