extends Node2D

@export var bullet_scene: PackedScene = preload("res://scenes/props/Bullet.tscn")
@export var muzzle_distance: float = 18.0   # how far in front of player to spawn

@onready var player := get_parent()  # Player is the parent

func _ready() -> void:
	player.connect("shot", _on_player_shot)

func _on_player_shot(dir: Vector2) -> void: 
	var b = bullet_scene.instantiate()
	print("bullet instanced at: ", b)
	# spawn point = player + direction * distance
	var spawn_pos = player.global_position + dir.normalized() * muzzle_distance
	b.global_position = spawn_pos
	b.velocity = dir.normalized() * b.speed
	get_tree().current_scene.add_child(b)

func shoot(dir: Vector2) -> void:
	if bullet_scene == null:
		push_error("Shooter: Bullet Scene not set")
		return

	# create the bullet
	var b = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)

	# spawn a bit in front of the shooter
	b.global_position = global_position + dir.normalized() * muzzle_distance

	# give it velocity/speed (Bullet.gd defines @export var speed and var velocity)
	b.velocity = dir.normalized() * b.speed

	print("bullet instanced at ", b.global_position)
