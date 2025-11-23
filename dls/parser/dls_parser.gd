extends Node
class_name DSLParser

func parse_dsl(text: String) -> Dictionary:
	var chests := {}
	var current_chest := ""
	
	for line in text.split("\n"):
		line = line.strip_edges(true, true)
		
		if line.begins_with("bau_id"):
			# bau_id "bau_inicial" {
			current_chest = line.split("\"")[1]
			chests[current_chest] = []
		
		elif line.begins_with("moedas"):
			# moedas = random({20, 40, 60})
			var inside := line.get_slice("{", 1).get_slice("}", 0)
			var values := []
			
			for token in inside.split(","):
				values.append(int(token.strip_edges(true, true)))
			
			chests[current_chest] = values

	return chests
