extends Area2D

@export var speed = 400 # How fast the bullet will move (pixels/sec).
var screen_size # Size of the game window.
var velocity := Vector2.ZERO # The bullet's movement vector.

# Logic to detach bullet from player and reattach to world
func _on_shoot():
	var original_global_position = global_position
	var new_parent = get_tree().root
	var parent = get_parent()
	parent.remove_child(self)
	new_parent.add_child(self)
	global_position = original_global_position
	$AnimatedSprite2D.play("shoot")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		velocity = Vector2.RIGHT * speed
		_on_shoot()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
