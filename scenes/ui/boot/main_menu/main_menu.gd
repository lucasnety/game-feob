extends Control

func _on_btn_novo_jogo_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/boot/loading/city_loading.tscn")

func _on_btn_continuar_pressed():
	print("Continuar ainda não implementado.")

func _on_btn_sair_pressed():
	get_tree().quit()
