extends Area2D

@onready var nav : NavigationAgent2D = $NavigationAgent2D
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemy")
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play("default")
	update_path()

	# Set Destination
func update_path():
	nav.target_position = MainInstance.player.global_position

func _physics_process(delta: float) -> void:
	if not finished:
		update_path()
		var direction = (nav.get_next_path_position() - global_position).normalized()
		translate(direction * 200 * delta)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		$AnimatedSprite2D.play("hurt")
