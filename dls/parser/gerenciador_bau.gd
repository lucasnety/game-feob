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

func get_random_coins(chest_id: String) -> int:
	if not chests.has(chest_id):
		push_error("ChestManager: chest_id not found: %s" % chest_id)
		return 0
	
	var values = chests[chest_id]
	if values.is_empty():
		return 0
	
	return values[randi() % values.size()]
