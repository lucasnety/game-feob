extends AudioStreamPlayer3D

func _ready():
	if stream:
		stream.loop = true
	volume_db = -30.0     # começa baixo
	play()
	
	# efeito de aumento suave da música
	create_tween().tween_property(self, "volume_db", -4.0, 4.0)
