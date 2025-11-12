extends PanelContainer

const Slot = preload("res://inventario/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid


var inventory_data: InventoryData

func set_inventory_data(data: InventoryData) -> void:
	inventory_data = data  

	data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(data)


func clear_inventory_data(data: InventoryData) -> void:
	if data.inventory_updated.is_connected(populate_item_grid):
		data.inventory_updated.disconnect(populate_item_grid)


func populate_item_grid(data: InventoryData) -> void:
	# Clear old slots
	for child in item_grid.get_children():
		child.queue_free()

	# Rebuild inventory slots
	for slot_data in data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)

		slot.slot_cliked.connect(data.on_slot_cliked)

		if slot_data:
			slot.set_slot_data(slot_data)
