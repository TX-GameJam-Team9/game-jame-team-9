extends Node2D
signal cleared(room)
signal door_entered(room, direction: String)

@onready var tilemap: TileMap = $TileMap
@onready var doors: Node = $Doors
@onready var enemy_spawns: Node = $EnemySpawns

@export var enemy_scene: PackedScene          # set to res://scenes/Enemy.tscn in Inspector
@export var max_enemies: int = 64
@export var spawn_chunk_max: int = 4          # 0..this many per tick
@export var spawn_cooldown: float = 1.5       # seconds between ticks

@onready var spawn_points: Node = $EnemySpawns
@onready var spawn_timer: Timer = $EnemySpawnTimer

# Timer bits
@export var start_time_seconds: float = 90.0
@onready var game_timer: Node         = $CanvasLayer/GameTimer
@onready var time_label: Label        = $CanvasLayer/HUD/TimeLabel
@onready var time_bar: ProgressBar    = $CanvasLayer/HUD/TimeBar

var _alive := 0
var _entered := false

func _ready() -> void:
	randomize()
	# Hook up UI and start timer
	#print("[ROOM] _ready, hooking timer…")
	game_timer.hook_label(time_label)
	game_timer.hook_bar(time_bar)
	game_timer.start(90.0)  # or timer.start(start_time_seconds)
	#print("[ROOM] started: running=", game_timer.running, " is_processing=", game_timer.is_processing())
	spawn_timer.wait_time = spawn_cooldown
	if not spawn_timer.timeout.is_connected(_on_spawn_tick):
		spawn_timer.timeout.connect(_on_spawn_tick)
	spawn_timer.start()

	# (optional) start with a few on room enter
	_spawn_initial()

func _alive_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func _capacity() -> int:
	return max(0, max_enemies - _alive_count())

func _pick_spawn_pos() -> Vector2:
	# pick a random child under EnemySpawns; if none, spawn near player
	if spawn_points.get_child_count() > 0:
		var m := spawn_points.get_child(randi() % spawn_points.get_child_count())
		if m is Node2D:
			return (m as Node2D).global_position
	# Fallback: around the player in a ring
	var p := MainInstance.player.global_position
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	return p + dir * 300.0

func _spawn_one() -> void:
	if _capacity() <= 0 or enemy_scene == null:
		return
	var e := enemy_scene.instantiate()
	(e as Node2D).global_position = _pick_spawn_pos()
	get_tree().current_scene.add_child(e)  # or add_child(e) if Room is the gameplay root

func _on_spawn_tick() -> void:
	var cap := _capacity()
	if cap <= 0:
		return

	var need_at_least_one := (_alive_count() == 0)  # if all dead, force spawn ≥1
	var n := randi_range(0, spawn_chunk_max)
	if need_at_least_one:
		n = max(1, n)
	n = min(n, cap)

	for i in n:
		_spawn_one()
func _spawn_initial() -> void:
	var n := 4
	for i in n:
		_spawn_one()
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
