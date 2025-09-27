extends Area2D
signal entered(direction: String)

@export var direction := "E"      # "N","E","S","W"
@export var locked := true

@onready var blocker: StaticBody2D     = $Blocker
@onready var trigger: CollisionShape2D = $CollisionShape2D
@onready var sprite := $Sprite2D       # or $AnimatedSprite2D if you used that

func _ready() -> void:
	set_locked(locked)
	body_entered.connect(_on_body_entered)

func set_locked(v: bool) -> void:
	locked = v

	# 1) Toggle the physical blocker
	for c in blocker.get_children():
		if c is CollisionShape2D:
			c.disabled = not v
	blocker.visible = v  # optional: show a panel when closed

	# 2) Toggle the visual
	if sprite and sprite is AnimatedSprite2D:
		sprite.play( locked ? "closed" : "open" )
	elif sprite and sprite is Sprite2D:
		# simple color cue for now (red = closed, green = open)
		sprite.modulate = locked ? Color(0.85, 0.25, 0.25) : Color(0.25, 0.85, 0.25)
		# optional: hide sprite when open if you want an empty doorway
		# sprite.visible = locked

func _on_body_entered(body: Node) -> void:
	if locked:
		return
	if body.is_in_group("player"):   # your teammate can add Player to 'player' group
		emit_signal("entered", direction)
