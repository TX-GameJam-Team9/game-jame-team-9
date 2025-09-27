extends Area2D
signal entered(direction: String)

@export var direction := "E"   # "N","E","S","W"
@export var locked := true

@onready var blocker: StaticBody2D = $Blocker

func _ready() -> void:
	set_locked(locked)
	connect("body_entered", Callable(self, "_on_body_entered"))

func set_locked(v: bool) -> void:
	locked = v
	# Show/hide and enable/disable the blocking collider
	blocker.visible = v
	# Disable the StaticBody’s shapes when unlocked
	for child in blocker.get_children():
		if child is CollisionShape2D:
			child.disabled = not v

func _on_body_entered(body: Node) -> void:
	# Later your Player will be in group "player"
	if not locked and body.is_in_group("player"):
		emit_signal("entered", direction)
