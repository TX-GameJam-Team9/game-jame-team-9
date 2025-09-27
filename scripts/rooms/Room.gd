extends Node2D
signal cleared(room)
signal door_entered(room, direction: String)

@onready var tilemap: TileMap = $TileMap
@onready var doors: Node = $Doors
@onready var enemy_spawns: Node = $EnemySpawns

var _alive := 0
var _entered := false

func on_enter() -> void:
	if _entered: return
	_entered = true
	_lock_doors(true)
	_spawn_wave()

# ---- Camera bounds for the room (in pixels)
func get_bounds() -> Rect2:
	var used: Rect2i = tilemap.get_used_rect()   # tile coords of painted area
	var tile := tilemap.tile_set.tile_size       # Vector2i (px per tile)
	var pos_px := tilemap.to_global(tilemap.map_to_local(used.position))
	var size_px := Vector2(used.size) * Vector2(tile)
	return Rect2(pos_px, size_px)

# ---- Minimal wave (stub): unlock immediately after a tick
func _spawn_wave() -> void:
	# Replace with real Enemy spawns later
	_alive = enemy_spawns.get_child_count()
	await get_tree().create_timer(0.1).timeout
	_alive = 0
	_check_clear()

func _check_clear() -> void:
	if _alive <= 0:
		_lock_doors(false)
		emit_signal("cleared", self)

func _lock_doors(v: bool) -> void:
	for d in doors.get_children():
		d.call("set_locked", v)
		if not d.is_connected("entered", Callable(self, "_on_door_entered")):
			d.connect("entered", Callable(self, "_on_door_entered"))

func _on_door_entered(dir: String) -> void:
	emit_signal("door_entered", self, dir)
