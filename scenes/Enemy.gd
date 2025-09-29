extends Area2D

@onready var enemy_death_sfx: AudioStreamPlayer2D = $Enemy_Death_SFX
@onready var enemy_hurt_sfx: AudioStreamPlayer2D = $Enemy_Hurt_SFX
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

@export var speed: float = 120.0
@export var hits_to_kill: int = 5
@export var time_reward: float = 6.0

var hits := 0
var finished := false
var anim_name := "default"
var game_timer: Node = null

func _ready() -> void:
	randomize()
	add_to_group("enemy")

	var names := sprite.sprite_frames.get_animation_names()
	var idle_pool: Array[StringName] = []
	for n in names:
		if n != "death" and n != "hurt":
			idle_pool.append(n)

	if idle_pool.size() == 0:
		anim_name = "default"  # fallback if only death/hurt exist
	else:
		anim_name = idle_pool[randi() % idle_pool.size()]

	sprite.play(anim_name)

	# Make sure death/hurt don't loop (just in case the resource was set to loop)
	if sprite.sprite_frames.has_animation("death"):
		sprite.sprite_frames.set_animation_loop("death", false)
	if sprite.sprite_frames.has_animation("hurt"):
		sprite.sprite_frames.set_animation_loop("hurt", false)

	# Cache reference to timer (adjust path if needed)
	game_timer = get_tree().root.get_node("RoomBase/CanvasLayer/GameTimer")

	# Connect animation_finished if not already
	if not sprite.is_connected("animation_finished", Callable(self, "_on_AnimatedSprite2D_animation_finished")):
		sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

	# Connect area_entered if not already
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		area_entered.connect(_on_area_entered)

	update_path()

func update_path():
	if not finished:
		nav.target_position = MainInstance.player.global_position

func _physics_process(delta: float) -> void:
	if finished:
		return
	update_path()
	var direction := (nav.get_next_path_position() - global_position).normalized()
	translate(direction * speed * delta)

func _on_area_entered(area: Area2D) -> void:
	if finished:
		return

	if area.is_in_group("bullet"):
		if is_instance_valid(area):
			area.queue_free()

		hits += 1

		if hits < hits_to_kill:
			anim_name = "hurt"
			sprite.play("hurt")
			return

		# KILLED
		finished = true
		anim_name = "death"
		collider.disabled = true
		sprite.play("death")
		enemy_death_sfx.play()
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
			sprite.sprite_frames.set_animation_loop("death", false)
			sprite.play("death")
			await sprite.animation_finished   # wait exactly one finish

		if game_timer:
			game_timer.add_time(time_reward)

func _on_AnimatedSprite2D_animation_finished() -> void:
	if anim_name == "death" and finished:
		queue_free()
	elif anim_name == "hurt" and not finished:
		anim_name = "default"
		sprite.play(anim_name)
		enemy_hurt_sfx.play()
