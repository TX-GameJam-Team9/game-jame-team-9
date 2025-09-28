class_name Player
extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var is_shooting = false
@onready var shooter = $Shooter

func _enter_tree() -> void:
	MainInstance.player = self

func after_shoot(anim_name):
	if anim_name == "shoot":
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.play()
		is_shooting = false

func shoot_animation():
	if is_shooting:
		return
	is_shooting = true
	$AnimatedSprite2D.animation="shoot"
	$AnimatedSprite2D.play()
	#aim with mouse
	var dir := (get_global_mouse_position() - global_position).normalized()
	emit_signal("shot", dir)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(after_shoot)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO
	var to_mouse: Vector2 = get_global_mouse_position() - global_position

	# Handle shooting input
	if Input.is_action_just_pressed("shoot"):
		print("Shots fired!") 
		shoot_animation()
		
		var dir: Vector2 = (get_global_mouse_position() - $Shooter.global_position).normalized()
		$Shooter.look_at(get_global_mouse_position())
		$Shooter.shoot(dir)

	# Movement input
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Handle animation and direction
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x > 0
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	self.velocity = velocity
	move_and_slide()
	
