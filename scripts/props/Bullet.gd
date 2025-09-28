extends Area2D

@onready var slime_sprite: AnimatedSprite2D = $Slime_Sprite
@export var speed: float = 600.0              # bullet speed (px/s)
@export var lifetime: float = 0.0             # 0 = infinite; >0 auto-despawn after seconds
var velocity: Vector2 = Vector2.ZERO          # set by Shooter
var health = 0
var Slime_State = "default"

func set_direction(dir: Vector2) -> void:
	# Shooter calls this after instancing
	velocity = dir.normalized() * speed

func _ready() -> void:
	add_to_group("bullet")
	# Optional lifetime
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(queue_free)
	

	# Hook collision signals (works for both bodies and areas)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# (Optional) auto-clean if it leaves the screen (add a VisibilityNotifier2D node to use this)
	if has_node("VisibilityNotifier2D"):
		$VisibilityNotifier2D.screen_exited.connect(queue_free)

# Movement
func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	
#Trying to get this to be body entering
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		print("Larry's been shot")
		queue_free()
	if body.is_in_group("player"):
		return

func _on_area_entered(area: Area2D) -> void:
	# Same rule for Area2D enemies/obstacles
	if area.is_in_group("player"):
		return
	if area.is_in_group("enemy"):
		Slime_State = "Hit"
		$Slime_Sprite.play(Slime_State)
	
func _on_slime_sprite_animation_finished() -> void:
	if $Slime_Sprite.animation_finished:
		queue_free()
