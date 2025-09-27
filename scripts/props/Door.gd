extends Area2D
signal entered(direction: String)

@export var direction := "E"
@export var locked: bool = true : set = set_locked   # <-- call set_locked whenever it changes

@onready var blocker: StaticBody2D     = $Blocker
@onready var trigger: CollisionShape2D = $CollisionShape2D
@onready var sprite                    = $Sprite2D    # or $AnimatedSprite2D

func _ready() -> void:
	set_locked(locked)
	body_entered.connect(_on_body_entered)

func set_locked(v: bool) -> void:
	locked = v
	if !is_node_ready():
		return

	# Toggle the physical blocker
	for c in blocker.get_children():
		if c is CollisionShape2D:
			c.disabled = not v
	blocker.visible = v   # optional visual for the blocker

	# Visual feedback
	if sprite and sprite is AnimatedSprite2D:
		sprite.play("closed" if v else "open")
	elif sprite and sprite is Sprite2D:
		sprite.modulate = Color(0.85, 0.25, 0.25) if v else Color(0.25, 0.85, 0.25)

	print("Door locked =", locked)

func _on_body_entered(body: Node) -> void:
	if locked:
		return
	if body.is_in_group("player"):   # your teammate can add Player to 'player' group
		emit_signal("entered", direction)
