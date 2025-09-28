extends Node2D
signal cleared(room)
signal door_entered(room, direction: String)

@onready var tilemap: TileMap = $TileMap
@onready var doors: Node = $Doors
@onready var enemy_spawns: Node = $EnemySpawns

# Timer bits
@export var start_time_seconds: float = 90.0
@onready var game_timer: Node         = $CanvasLayer/GameTimer
@onready var time_label: Label        = $CanvasLayer/HUD/TimeLabel
@onready var time_bar: ProgressBar    = $CanvasLayer/HUD/TimeBar

var _alive := 0
var _entered := false

func _ready() -> void:
	# Hook up UI and start timer
	#print("[ROOM] _ready, hooking timer…")
	game_timer.hook_label(time_label)
	game_timer.hook_bar(time_bar)
	game_timer.start(90.0)  # or timer.start(start_time_seconds)
	#print("[ROOM] started: running=", game_timer.running, " is_processing=", game_timer.is_processing())

func _on_time_up() -> void:
	print("Time up → Lose screen / reload room")

func _on_win() -> void:
	print("You win! → Next room / victory screen")

func on_enter() -> void:
	if _entered: return
	_entered = true
	_lock_doors(true)
	_spawn_wave()

# ---- Camera bounds for the room (in pixels)
func get_bounds() -> Rect2:
	var used: Rect2i = tilemap.get_used_rect()
	var tile := tilemap.tile_set.tile_size
	var pos_px := tilemap.to_global(tilemap.map_to_local(used.position))
	var size_px := Vector2(used.size) * Vector2(tile)
	return Rect2(pos_px, size_px)

# ---- Minimal wave (stub): unlock immediately after a tick
func _spawn_wave() -> void:
	_alive = enemy_spawns.get_child_count()
	await get_tree().create_timer(0.1).timeout
	_alive = 0
	_check_clear()

func _check_clear() -> void:
	if _alive <= 0:
		_lock_doors(false)
		emit_signal("cleared", self)
		# If your “win” condition is “room cleared before time runs out”:
		# game_timer.win_now()

func _lock_doors(v: bool) -> void:
	for d in doors.get_children():
		d.call("set_locked", v)
		if not d.is_connected("entered", Callable(self, "_on_door_entered")):
			d.connect("entered", Callable(self, "_on_door_entered"))

func _on_door_entered(dir: String) -> void:
	emit_signal("door_entered", self, dir)
