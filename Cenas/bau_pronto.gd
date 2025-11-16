extends Node3D

var animator: AnimationPlayer = null

func _ready():
	# procura a mesh do baú
	var mesh = get_node_or_null("bau")
	if not mesh:
		push_warning("⚠️ Não encontrei o node 'bau' no baú!")
		return

	# procura o AnimationPlayer dentro da mesh
	animator = mesh.get_node_or_null("AnimationPlayer")

	if not animator:
		push_warning("⚠️ Não encontrei AnimationPlayer dentro de bau!")
		return

func _input(event):
	# tecla M já mapeada como 'interact'
	if event.is_action_pressed("interact"):
		_play_bau_anim()

func _play_bau_anim():
	if animator and animator.has_animation("bau/bau"):
		animator.play("bau/bau")
	else:
		push_warning("⚠️ A animação 'bau/bau' não existe no AnimationPlayer!")
