extends Node # GameTimer.gd

signal time_changed(seconds_left: float)
signal timer_ended
signal player_won
signal player_lost

@export var start_seconds: float = 90.0
@export var clamp_min: float = 0.0
@export var clamp_max: float = 600.0
@export var running: bool = false

var time_left: float
var _label: Label = null
var _bar: ProgressBar = null   # <- optional progress bar

func _enter_tree() -> void:
	print("[TIMER] enter_tree")

func _ready() -> void:
	print("[TIMER] ready on:", self.get_path())
	time_left = start_seconds
	# In case a ProgressBar is a child named "TimeBar", auto-grab it:
	if has_node("TimeBar"):
		_bar = get_node("TimeBar") as ProgressBar
		# Make the bar use seconds directly for easy updates:
		_bar.min_value = 0
		_bar.max_value = start_seconds
	_update_ui()
	set_process(running)
	print("[TIMER] after _ready: running=", running, " is_processing=", is_processing())

func hook_label(label: Label) -> void:
	_label = label
	_update_ui()

func hook_bar(bar: ProgressBar) -> void:
	_bar = bar
	_bar.min_value = 0
	_bar.max_value = start_seconds
	_update_ui()

func start(seconds: float = -1.0) -> void:
	if seconds >= 0.0:
		time_left = clampf(seconds, clamp_min, clamp_max)
	running = true
	set_process(true)
	emit_signal("time_changed", time_left)
	_update_ui()

func stop() -> void:
	running = false
	set_process(false)

func reset() -> void:
	time_left = clampf(start_seconds, clamp_min, clamp_max)
	running = false
	set_process(false)
	emit_signal("time_changed", time_left)
	_update_ui()

func add_seconds(amount: float) -> void:
	time_left = clampf(time_left + amount, clamp_min, clamp_max)
	emit_signal("time_changed", time_left)
	_update_ui()
	if time_left <= 0.0:
		_on_time_up()

func _process(delta: float) -> void:
	if !running:
		return
	time_left = max(clamp_min, time_left - delta)
	emit_signal("time_changed", time_left)
	_update_ui()
	#print("DEBUG | time_left =", time_left)  # 👈 Add this line
	if time_left <= 0.0:
		print("call _on_time_up()")
		_on_time_up()

func _on_time_up() -> void:
	running = false
	set_process(false)
	emit_signal("timer_ended")
	emit_signal("player_lost")

func win_now() -> void:
	running = false
	set_process(false)
	emit_signal("player_won")

func _update_ui() -> void:
	if _label:
		_label.text = _fmt(time_left)
	if _bar:
		_bar.value = time_left  # since max_value == start_seconds
		_bar.max_value = start_seconds

func _fmt(seconds: float) -> String:
	var s := int(round(seconds))
	@warning_ignore("integer_division")
	var m := s / 60
	var r := s % 60
	return "%02d:%02d" % [m, r]
	
func add_time(amount: float) -> void:
	time_left = clampf(time_left + amount, clamp_min, clamp_max)
	emit_signal("time_changed", time_left)
	_update_ui()
	if time_left <= clamp_min:
		_on_time_up()

# Remove time but never below 0
func remove_time(amount: float) -> void:
	time_left = clampf(time_left - amount, clamp_min, clamp_max)
	emit_signal("time_changed", time_left)
	_update_ui()
	if time_left <= clamp_min:
		print("call on_time_up")
		_on_time_up()
