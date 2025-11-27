extends AudioStreamPlayer3D

func _ready():
	
	attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	max_distance = 200

	
	emission_angle_degrees = 360
	emission_angle_filter_attenuation_db = 0

	
	doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED

	
	panning_strength = 0.0

	if stream:
		stream.loop = true

	volume_db = -30.0
	play()

	create_tween().tween_property(self, "volume_db", -14.0, 4.0)
