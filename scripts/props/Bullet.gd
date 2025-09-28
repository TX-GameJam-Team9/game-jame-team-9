extends Area2D

@export var speed: float = 600.0              # bullet speed (px/s)
@export var lifetime: float = 0.0             # 0 = infinite; >0 auto-despawn after seconds
var velocity: Vector2 = Vector2.ZERO          # set by Shooter

func set_direction(dir: Vector2) -> void:
	# Shooter calls this after instancing
	velocity = dir.normalized() * speed

func _ready() -> void:
	# Optional lifetime
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(queue_free)

	# Hook collision signals (works for both bodies and areas)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# (Optional) tint the temp sprite so it's visible
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 0, 0)

	# (Optional) auto-clean if it leaves the screen (add a VisibilityNotifier2D node to use this)
	if has_node("VisibilityNotifier2D"):
		$VisibilityNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node) -> void:
	# Ignore player; stop on anything else (e.g., walls, enemies)
	if body.is_in_group("player"):
		return
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Same rule for Area2D enemies/obstacles
	if area.is_in_group("player"):
		return
	queue_free()
