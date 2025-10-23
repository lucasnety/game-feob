extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 100000000

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantidade: int = 1: set = set_quantity

func set_quantity(value: int) -> void: 
	quantidade = value
	if quantidade > 1 and not item_data.stackable:
		quantidade = 1 
		push_error("%s teste" % item_data.nome)
