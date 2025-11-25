extends Node
class_name ChestManager

var chests := {}

func _ready():
	load_dsl()

func load_dsl():
	var file := FileAccess.open("res://dls/baus.txt", FileAccess.READ)
	if file:
		var text := file.get_as_text()
		var parser := DSLParser.new()
		chests = parser.parse_dsl(text)
		print("DSL Loaded:", chests)
	else:
		push_error("Could not find DSL file!")

func get_random_loot(chest_id: String) -> Dictionary:
	if not chests.has(chest_id):
		return {}

	var data = chests[chest_id]
	var result := {}

	# random coins
	if data.has("moedas"):
		var list = data["moedas"]
		var random_value = list[randi() % list.size()]
		result["moedas"] = random_value

	# fragmento (fixed number)
	if data.has("fragmento"):
		result["fragmento"] = data["fragmento"]

	return result
