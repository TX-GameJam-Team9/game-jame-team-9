extends Area2D

@onready var player: Node2D = get_node("../../Player")
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@export var speed: float = 200.0
@export var hits_to_kill: int = 5
@export var time_reward: float = 6.0
var finished = false #finsihed is dead
var game_timer: Node = null 
var hits:= 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	update_path()
	game_timer = get_tree().root.get_node("RoomBase/CanvasLayer/GameTimer")
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

	# Set Destination
func update_path():
	nav.target_position = player.global_position

func _physics_process(delta: float) -> void:
<<<<<<< Updated upstream
	if not finished:
		update_path()
		var direction = (nav.get_next_path_position() - global_position).normalized()
		translate(direction * 200 * delta)
	
=======
	if finished:
		return
	update_path()
	var direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * 200 * delta)

func _on_area_entered(area: Area2D) -> void:
	if finished:
		return
	if area.is_in_group("bullet"):
		# optional: remove the bullet on hit
		if is_instance_valid(area):
			area.queue_free()

		hits += 1

		# small feedback while still alive
		if hits < hits_to_kill:
			$AnimatedSprite2D.play("hurt")

		if hits >= hits_to_kill:
			finished = true
			# reward exactly once
			if game_timer:
				game_timer.add_time(time_reward)

			# death anim if available, then free
			#if $AnimatedSprite2D.has_animation("death"):
				#$AnimatedSprite2D.play("death")
				#await $AnimatedSprite2D.animation_finished
			queue_free()
>>>>>>> Stashed changes
