extends PanelContainer
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.nome, item_data.descricao]

	if slot_data.quantidade > 1:
		quantity_label.text = "x%s" % slot_data.quantidade
		quantity_label.show()
