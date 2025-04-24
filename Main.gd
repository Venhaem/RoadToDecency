# res://Main.gd
# — Attach this to your Main (Control) node —

extends Control

# Logo bobbing parameters
const LOGO_BOB_AMPLITUDE = 10.0
const LOGO_BOB_SPEED     = TAU    # 2π

# Dawn/Dusk for smooth day→night fade
const DAWN_START  = 5.0    # 5 AM
const DAWN_END    = 7.0    # 7 AM
const DUSK_START  = 17.0   # 5 PM
const DUSK_END    = 19.0   # 7 PM

# Node refs
var path: Path2D
var follower: PathFollow2D
var runner: AnimatedSprite2D
var logo: Sprite2D
var step_sound: AudioStreamPlayer2D
var day_bg: TextureRect
var night_bg: TextureRect
var bar: TextureProgressBar
var bar_label: Label
var cw_lbl: Label
var goal_lbl: Label
var tk_lbl: Label
var kt_lbl: Label
var st_lbl: Label
var wt_in: LineEdit
var km_in: LineEdit
var log_btn: Button

# Internal for logo bob
var _logo_time = 0.0
var _logo_start_y = 0.0

func _ready() -> void:
	# 1) Path & runner
	path     = $Path2D
	follower = path.get_node("PathFollow2D")
	follower.rotates = false
	runner   = follower.get_node("Runner")

	# 2) Footstep sound setup
	step_sound = runner.get_node("StepSound")
	step_sound.stop()

	# 3) Logo bob
	logo = $Logo
	_logo_start_y = logo.position.y

	# 4) Backgrounds
	day_bg   = $DayBG
	night_bg = $NightBG
	day_bg.modulate.a   = 1.0
	night_bg.modulate.a = 0.0

	# 5) Progress bar setup
	bar        = $ProgressBar
	bar.min_value = 0
	bar.max_value = 100
	bar.value     = 0
	bar_label    = $ProgressLabel
	bar_label.text = "0%"

	# 6) Stat labels
	cw_lbl   = $RowCurrentWeight/current_weight_label
	goal_lbl = $RowGoalWeight/goal_weight_label
	tk_lbl   = $RowTotalKM/total_km_label
	kt_lbl   = $RowKMToday/km_today_label
	st_lbl   = $RowStreak/streak_label

	# 7) Inputs & Log button
	wt_in   = $InputRow/InputContainer/weight_input
	km_in   = $InputRow/InputContainer/km_input
	log_btn = $InputRow/log_btn
	log_btn.pressed.connect(Callable(self, "_on_log_pressed"))

	# 8) Set default input values
	wt_in.text = "%0.1f" % GameState.current_weight
	km_in.text = "0"

	# 9) Daily-streak reset
	_daily_reset_check()

	# 10) Init UI & runner
	_refresh_ui()
	_move_runner()
	runner.play("idle")

func _process(_delta: float) -> void:
	# Logo bob
	_logo_time += _delta
	logo.position.y = _logo_start_y + LOGO_BOB_AMPLITUDE * sin(_logo_time * LOGO_BOB_SPEED)

	# Runner scale & flip
	var t = follower.progress_ratio
	runner.scale = Vector2(0.198 + 0.3 * t, 0.198 + 0.3 * t)
	if runner.animation == "run":
		var L   = path.curve.get_baked_length()
		var cur = t * L
		var nxt = clamp(cur + 0.01 * L, 0.0, L)
		runner.flip_h = path.curve.sample_baked(nxt).x < path.curve.sample_baked(cur).x

	# Progress percent text
	bar_label.text = "%d%%" % int(bar.value)

	# Smooth day/night fade & runner tint
	_update_day_night_alpha()

func _refresh_ui() -> void:
	cw_lbl.text   = "%0.1f kg" % GameState.current_weight
	var left = max(GameState.current_weight - GameState.goal_weight, 0.0)
	goal_lbl.text = "%0.1f kg" % left
	tk_lbl.text   = "%0.1f km" % GameState.total_km
	kt_lbl.text   = "%0.1f km" % GameState.km_today
	st_lbl.text   = str(GameState.streak)

func _move_runner() -> void:
	var drop       = GameState.start_weight - GameState.current_weight
	var total_drop = GameState.start_weight - GameState.goal_weight
	var t          = clamp(drop / total_drop, 0.0, 1.0)
	follower.progress_ratio = t
	runner.scale           = Vector2(0.198 + 0.3 * t, 0.198 + 0.3 * t)
	bar.value              = t * bar.max_value
	bar_label.text         = "%d%%" % int(bar.value)

func _on_log_pressed() -> void:
	runner.play("run")
	step_sound.play()

	var new_w = wt_in.text.to_float()
	var new_k = km_in.text.to_float()
	if new_w <= 0.0 or new_k < 0.0:
		step_sound.stop()
		return

	var today = _today_iso()
	if GameState.last_log_date != today:
		if GameState.last_log_date == _yesterday_iso():
			GameState.streak += 1
		else:
			GameState.streak = 1
		GameState.last_log_date = today

	GameState.current_weight = new_w
	GameState.km_today       = new_k
	GameState.total_km      += new_k
	GameState.save_state()
	_refresh_ui()

	var drop       = GameState.start_weight - GameState.current_weight
	var total_drop = GameState.start_weight - GameState.goal_weight
	var target_t   = clamp(drop / total_drop, 0.0, 1.0)

	create_tween().tween_property(
		follower, "progress_ratio", target_t, 1.0
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)\
	 .connect("finished", Callable(self, "_on_run_complete"))
	create_tween().tween_property(
		bar, "value", target_t * bar.max_value, 0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _on_run_complete() -> void:
	runner.play("idle")
	step_sound.stop()

# — DAILY STREAK HELPERS —
func _today_iso() -> String:
	return Time.get_date_string_from_system(false)

func _yesterday_iso() -> String:
	var ts = Time.get_unix_time_from_system() - 86400.0
	var d  = Time.get_date_dict_from_unix_time(int(ts))
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

func _daily_reset_check() -> void:
	var today = _today_iso()
	if GameState.last_log_date != today:
		GameState.km_today = 0.0
		if GameState.last_log_date != "" and GameState.last_log_date != _yesterday_iso():
			GameState.streak = 0
		GameState.save_state()

# — DAY/NIGHT FADE & TINT —
func _update_day_night_alpha() -> void:
	var d = Time.get_time_dict_from_system(false)
	var h = d["hour"] + d["minute"]/60.0 + d["second"]/3600.0
	var alpha: float
	if h < DAWN_START:
		alpha = 1.0
	elif h < DAWN_END:
		alpha = (DAWN_END - h) / (DAWN_END - DAWN_START)
	elif h < DUSK_START:
		alpha = 0.0
	elif h < DUSK_END:
		alpha = (h - DUSK_START) / (DUSK_END - DUSK_START)
	else:
		alpha = 1.0
	night_bg.modulate.a = alpha
	runner.modulate    = Color(1,1,1).lerp(Color(0.6,0.6,0.8), alpha)
