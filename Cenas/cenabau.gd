extends Node3D

@onready var area: Area3D = $Area3D
var anim: AnimationPlayer
var label: Label
var player_in_area := false
var aberto := false

func _ready():
	anim = find_child("AnimationPlayer", true, false)

	if anim == null:
		push_error("❌ Nenhum AnimationPlayer encontrado dentro da cena do baú!")
		return

	# 🔥 Desativa loop da animação (CORRIGE O SEU BUG)
	if anim.has_animation("bau/abrir"):
		var a = anim.get_animation("bau/abrir")
		a.loop_mode = Animation.LOOP_NONE

		# Começa fechado
		anim.play("bau/abrir")
		anim.seek(0.0, true)
		anim.pause()

	# Label
	label = get_tree().current_scene.find_child("Label", true, false)
	if label:
		label.visible = false

	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)


func _on_enter(body):
	if body.name == "Player" and not aberto:
		player_in_area = true
		if label:
			label.visible = true
			label.text = "Aperte M para interagir"


func _on_exit(body):
	if body.name == "Player":
		player_in_area = false
		if label:
			label.visible = false


func _process(delta):
	if not aberto and player_in_area and Input.is_action_just_pressed("interact"):
		abrir_bau()


func abrir_bau():
	aberto = true

	if label:
		label.visible = false

	if anim:
		# Inicia do zero SEM loop
		anim.play("bau/abrir")
		anim.seek(0.0, true)

		# Espera a animação terminar uma única vez
		await anim.animation_finished

		# 🔒 Trava exatamente no momento 0.8
		anim.seek(0.8, true)
		anim.pause()
