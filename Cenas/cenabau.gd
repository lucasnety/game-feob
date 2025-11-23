extends Node3D

@export var chest_id: String = "bau_normal"
@export var player_inventory: InventoryData

@onready var area: Area3D = $Area3D
var anim: AnimationPlayer
var label: Label

var player_in_area := false
var opened := false


func _ready():
	anim = find_child("AnimationPlayer", true, false)

	if anim and anim.has_animation("bau/abrir"):
		var a = anim.get_animation("bau/abrir")
		a.loop_mode = Animation.LOOP_NONE
		anim.play("bau/abrir")
		anim.seek(0.0, true)
		anim.pause()

	label = get_tree().current_scene.find_child("Label", true, false)
	if label:
		label.visible = false

	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)


func _on_enter(body):
	if body.name == "Player" and not opened:
		player_in_area = true
		if label:
			label.visible = true
			label.text = "Press M to open"


func _on_exit(body):
	if body.name == "Player":
		player_in_area = false
		if label:
			label.visible = false


func _process(delta):
	if not opened and player_in_area and Input.is_action_just_pressed("interact"):
		await abrir_bau()
		open_chest()  # ← now gives coins after animation


func abrir_bau():
	opened = true

	if label:
		label.visible = false

	if anim:
		anim.play("bau/abrir")
		anim.seek(0.0, true)
		await anim.animation_finished
		anim.seek(0.8, true)
		anim.pause()



func open_chest():
	var coin_amount = GerenciadorBau.get_random_coins(chest_id)
	print("Chest gives:", coin_amount, "coins")
	add_coins_to_inventory(coin_amount)


func add_coins_to_inventory(amount: int):
	var coin_item: ItemData = load("res://item/items/moeda.tres")

	var slot := SlotData.new()
	slot.item_data = coin_item
	slot.quantidade = amount

	player_inventory.add_slot_data(slot)
