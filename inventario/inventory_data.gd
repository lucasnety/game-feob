extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	return null


func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	var return_slot_data: SlotData = null

	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data

	inventory_updated.emit(self)
	return return_slot_data


func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())

	inventory_updated.emit(self)

	if grabbed_slot_data.quantidade > 0:
		return grabbed_slot_data
	return null


func on_slot_cliked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)


func get_total_moedas() -> int:
	var total_moedas = 0
	for slot_data in slot_datas:
		if slot_data != null and slot_data.item_data != null:
			if slot_data.item_data.nome == "moeda":
				total_moedas += slot_data.quantidade
	return total_moedas
	

func add_slot_data(new_slot: SlotData) -> void:
	# Try to merge with existing slots
	for i in range(slot_datas.size()):
		var slot = slot_datas[i]
		if slot == null:
			continue

		if slot.can_fully_merge_with(new_slot):
			slot.fully_merge_with(new_slot)
			inventory_updated.emit(self)
			return

		if slot.can_merge_with(new_slot):
			slot.quantidade += new_slot.quantidade
			inventory_updated.emit(self)
			return

	# If no merge happened, find an empty slot
	for i in range(slot_datas.size()):
		if slot_datas[i] == null:
			slot_datas[i] = new_slot
			inventory_updated.emit(self)
			return

	# Inventory full: optional error
	push_warning("Inventory is full! Cannot add: %s" % new_slot.item_data.nome)
