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
var _death_fired:= false

func _room_rect_px() -> Rect2:
	var used: Rect2i = tilemap.get_used_rect()
	var tile := tilemap.tile_set.tile_size
	var pos_px := tilemap.to_global(tilemap.map_to_local(used.position))
	var size_px := Vector2(used.size) * Vector2(tile)
	return Rect2(pos_px, size_px)

func _rand_point_in_rect(rect: Rect2, margin: float = 64.0) -> Vector2:
	return Vector2(
		randf_range(rect.position.x + margin, rect.position.x + rect.size.x - margin),
		randf_range(rect.position.y + margin, rect.position.y + rect.size.y - margin)
	)

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
	if not game_timer.timer_ended.is_connected(_on_time_up):
		game_timer.timer_ended.connect(_on_time_up)
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
	var rect := _room_rect_px()
	var p := MainInstance.player.global_position if MainInstance.player else rect.get_center()
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	for i in 8:
		var pos := _rand_point_in_rect(rect, 96.0)
		if pos.distance_to(p) > 220.0:
			return pos
	return _rand_point_in_rect(rect, 96.0)  # fallback

func _spawn_one() -> void:
	if _death_fired: return
	if enemy_scene == null or _capacity() <= 0:
		return
	var e := enemy_scene.instantiate()
	(e as Node2D).global_position = _pick_spawn_pos()
	get_tree().current_scene.add_child(e)
	# When the enemy is freed, we’ll be notified:
	if not e.is_connected("tree_exited", Callable(self, "_on_enemy_left_tree")):
		e.connect("tree_exited", Callable(self, "_on_enemy_left_tree"))

func _on_enemy_left_tree() -> void:
	var cap := _capacity()
	if cap <= 0:
		return
	var n := randi_range(0, spawn_chunk_max)
	if not _death_fired and _alive_count() == 0:
		n = max(1, n)  # guarantee at least 1 if you just cleared them all
	n = min(n, cap)
	for i in range(n):
		_spawn_one()


func _on_spawn_tick() -> void:
	if _death_fired: return
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

func _clear_group(group_name: String) -> void:
	for n in get_tree().get_nodes_in_group(group_name):
		if is_instance_valid(n):
			n.queue_free()

func _on_time_up() -> void:
	print("Time is up, _on_time_up()")
	if _death_fired: return
	_death_fired = true

	# 1) Stop further spawns if you have a spawn timer
	if has_node("EnemySpawnTimer"):
		$EnemySpawnTimer.stop()

	# 2) Tell player to die (if present)
	if MainInstance.player and is_instance_valid(MainInstance.player):
		if MainInstance.player.has_method("die"):
			MainInstance.player.die()

	# 3) Clear enemies (and bullets) from the scene
	_clear_group("enemy")
	_clear_group("bullet")

	# 4) (Optional) small delay for the hurt animation / UX
	await get_tree().create_timer(3.5).timeout

	# 5) Quit the game
	get_tree().quit()

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
