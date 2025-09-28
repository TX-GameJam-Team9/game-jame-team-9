extends Area2D
@onready var enemy_death_sfx: AudioStreamPlayer2D = $Enemy_Death_SFX
@onready var enemy_hurt_sfx: AudioStreamPlayer2D = $Enemy_Hurt_SFX
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@export var speed: float = 30.0          # teammate had 30 in _physics_process
@export var hits_to_kill: int = 5        # how many bullet hits until death
@export var time_reward: float = 6.0     # seconds to add on kill

var finished := false                    # true once dead
var anim_name := "default"
var hits := 0                            # current hit count
var game_timer: Node = null              # set in _ready()efault"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemy")
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play(anim_name)
	# cache timer (adjust path if your HUD layout changes)
	game_timer = get_tree().root.get_node("RoomBase/CanvasLayer/GameTimer")

	# ensure we react to bullet overlaps (if not already wired in the scene)
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))
	update_path()

	# Set Destination
func update_path():
	nav.target_position = MainInstance.player.global_position

func _physics_process(delta: float) -> void:
	if finished:
		return
	update_path()
	var direction := (nav.get_next_path_position() - global_position).normalized()
	translate(direction * speed * delta)

# Detects if shot; increments hit counter; awards time on kill
func _on_area_entered(area: Area2D) -> void:
	if finished:
		return
	if area.is_in_group("bullet"):
		# optional: remove bullet on hit so it doesn't multi-hit this frame
		if is_instance_valid(area):
			area.queue_free()

		hits += 1
		

		if hits < hits_to_kill:
			anim_name = "hurt"
			$AnimatedSprite2D.play(anim_name)
			return

		# KILLED
		finished = true
		if game_timer:
			game_timer.add_time(time_reward)
		# play death here if you have one; otherwise just free
		queue_free()

# Goes back to idle once hurt animation finishes (unless already killed)
func _on_animated_sprite_2d_animation_finished() -> void:
	if finished:
		return
	if anim_name == "hurt":
		anim_name = "default"
		$AnimatedSprite2D.play(anim_name)
		$Enemy_Hurt_SFX.play()
