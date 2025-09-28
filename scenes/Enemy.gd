extends Area2D

@onready var nav : NavigationAgent2D = $NavigationAgent2D
var finished = false
var anim_name = "default"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemy")
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play(anim_name)
	update_path()

	# Set Destination
func update_path():
	nav.target_position = MainInstance.player.global_position

func _physics_process(delta: float) -> void:
	if not finished:
		update_path()
		var direction = (nav.get_next_path_position() - global_position).normalized()
		translate(direction * 200 * delta)

#Detects if shot, plays hurt animation if it is
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		anim_name = "hurt"
		$AnimatedSprite2D.play(anim_name)

#Goes back to idle once hit
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_name == "hurt":
		anim_name = "default"
		$AnimatedSprite2D.play(anim_name)
