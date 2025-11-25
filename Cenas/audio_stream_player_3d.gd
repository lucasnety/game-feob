extends AudioStreamPlayer3D

func _ready() -> void:
	if stream:
		stream.loop = true  # força o loop automático
