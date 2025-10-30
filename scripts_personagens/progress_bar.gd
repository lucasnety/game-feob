extends ProgressBar  # então o script vai no nó ProgressBar

var target_scene: String = ""

func start_loading(scene_path: String) -> void:
	target_scene = scene_path
	value = 0
	await animate_loading()

func animate_loading() -> void:
	for i in range(101):
		value = i
		await get_tree().process_frame
	get_tree().change_scene_to_file(target_scene)
