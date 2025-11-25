extends Node
class_name DSLParser

func parse_dsl(text: String) -> Dictionary:
	var chests := {}
	var current_chest := ""

	for line in text.split("\n"):
		line = line.strip_edges()   # ← Godot 4 correct function

		if line.begins_with("bau_id"):
			current_chest = line.split("\"")[1]
			chests[current_chest] = {}  # dictionary for this chest

		elif line.begins_with("moedas"):
			# extract {20,40,60}
			var inside := line.get_slice("{", 1).get_slice("}", 0)
			var values := []
			for token in inside.split(","):
				values.append(int(token.strip_edges()))
			chests[current_chest]["moedas"] = values

		elif line.begins_with("fragmento"):
			if "{" in line and "}" in line:
				var inside := line.get_slice("{", 1).get_slice("}", 0)
				var values := []
				for token in inside.split(","):
					values.append(int(token.strip_edges()))
					chests[current_chest]["fragmento"] = values
			else:
				var number := int(line.split("=")[1].strip_edges())
				chests[current_chest]["fragmento"] = number

	return chests
