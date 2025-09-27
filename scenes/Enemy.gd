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
	# Toggle blocker collider on/off
	for child in blocker.get_children():
		if child is CollisionShape2D:
			child.disabled = not v
	blocker.visible = v   # optional, if you give Blocker a sprite later

func _on_body_entered(body: Node) -> void:
	if not locked and body.is_in_group("player"):
		emit_signal("entered", direction)
