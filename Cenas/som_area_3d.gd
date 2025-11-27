extends Area3D

@onready var city_music: AudioStreamPlayer3D = $CityMusic

func _ready():
	city_music.loop = true
	print("Som da cidade pronto.")  # Debug

func _on_Som_area3D_body_entered(body):
	print("Entrou:", body.name)     # Debug
	if body.is_in_group("player"):
		print("Tocando música da cidade...")
		city_music.play()

func _on_Som_area3D_body_exited(body):
	if body.is_in_group("player"):
		print("Parando música da cidade...")
		city_music.stop()
