class_name Player
extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var player_anim = "idle"
var last_facing_right := false
@onready var shooter = $Shooter

@onready var walk_sfx = $Walk_SFX
var game_timer: Node = null

func _enter_tree() -> void:
	MainInstance.player = self

func after_shoot(anim_name):
	if anim_name == "shoot":
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.play()

func shoot_animation():
	player_anim = "shoot"
	$AnimatedSprite2D.play(player_anim)
	#aim with mouse
	var dir := (get_global_mouse_position() - global_position).normalized()
	emit_signal("shot", dir)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play(player_anim)
	$AnimatedSprite2D.animation_finished.connect(after_shoot)

	# grab the timer node
	game_timer = get_tree().root.get_node("RoomBase/CanvasLayer/GameTimer")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO
	var to_mouse: Vector2 = get_global_mouse_position() - global_position

	# Handle shooting input
	if Input.is_action_just_pressed("shoot"):
		print("Shots Fired!")
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
		if player_anim != "hurt" && player_anim != "shoot":
			player_anim = "walk"
		velocity = velocity.normalized() * speed

		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x > 0
		$AnimatedSprite2D.play()
		if not walk_sfx.playing:
			walk_sfx.play()


	if velocity.x != 0:
		last_facing_right = velocity.x > 0
		$AnimatedSprite2D.flip_h = last_facing_right
	if not walk_sfx.playing:
		walk_sfx.play()
	elif velocity.y != 0:
		$AnimatedSprite2D.flip_h = last_facing_right
		$AnimatedSprite2D.play(player_anim)
	if not walk_sfx.playing:
		walk_sfx.play()

	if velocity.length() == 0 && player_anim == "walk":
			$AnimatedSprite2D.stop()

	self.velocity = velocity
	move_and_slide()
	
# Enemy collision
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		take_damage()
		player_anim = "hurt"
		$AnimatedSprite2D.play(player_anim)

# Reset animation when done
func _on_animated_sprite_2d_animation_finished() -> void:
	if player_anim != "idle":
		player_anim = "idle"
		$AnimatedSprite2D.play(player_anim)

# Timer damage hook
func take_damage():
	if game_timer:
		game_timer.remove_time(10.0)
	print("Player took damage!")
		
