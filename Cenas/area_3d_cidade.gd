extends Area3D

@onready var city_music: AudioStreamPlayer3D = $"../CityMusic"  # ajusta se necessário

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if city_music and city_music.stream:
			city_music.stream.loop = true
			city_music.play()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if city_music:
			city_music.stop()    # opcional – só se quiser parar ao sair
