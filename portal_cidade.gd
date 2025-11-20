extends Node3D

@onready var area = $Area3D
@onready var label_m = $CanvasLayer/Label
@onready var anim = $AnimationPlayer

var player_dentro = false
var player_ref: CharacterBody3D = null

func _ready():
	label_m.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_dentro = true
		player_ref = body
		label_m.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_dentro = false
		label_m.visible = false

func _process(delta):
	if player_dentro and Input.is_action_just_pressed("interact"):
		anim.play("bau")
		label_m.visible = false
