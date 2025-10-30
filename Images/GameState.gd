extends Node

# Dificuldade
var dificuldade: String = "Normal"

# Dados do player
var vida: int = 100
var moedas: int = 0

# Transform do player entre cenas
var player_position: Vector3 = Vector3.ZERO
var player_rotation: Basis = Basis()
