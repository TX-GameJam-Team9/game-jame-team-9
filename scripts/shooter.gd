extends Node

@export var bullet_scene: PackedScene = preload("res://scenes/props/Bullet.tscn")
@export var muzzle_distance: float = 18.0   # how far in front of player to spawn

@onready var player := get_parent()  # Player is the parent

func _ready() -> void:
	player.connect("shot", _on_player_shot)

func _on_player_shot(dir: Vector2) -> void:
	var b = bullet_scene.instantiate()
	# spawn point = player + direction * distance
	var spawn_pos = player.global_position + dir.normalized() * muzzle_distance
	b.global_position = spawn_pos
	b.velocity = dir.normalized() * b.speed
	get_tree().current_scene.add_child(b)
