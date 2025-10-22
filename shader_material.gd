extends MeshInstance3D

func _ready():
	var shader_code = """
		shader_type spatial;

		uniform float glow_strength = 3.0;
		uniform vec4 fire_color : hint_color = vec4(1.0, 0.5, 0.0, 1.0);

		void fragment() {
			float glow = abs(sin(TIME * 5.0));
			vec3 emission = fire_color.rgb * glow * glow_strength;
			ALBEDO = vec3(0.1, 0.05, 0.0);
			EMISSION = emission;
		}
	"""

	var shader = Shader.new()
	shader.code = shader_code

	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader

	self.material_override = shader_material
