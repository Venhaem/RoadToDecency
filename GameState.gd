extends Node

const SAVE_PATH := "user://save.cfg"

var start_weight   := 120.0
var goal_weight    := 80.0

var current_weight := start_weight
var total_km       := 0.0
var km_today       := 0.0
var streak         := 0
var last_log_date  := ""   # “YYYY-MM-DD” of the last day you logged

func _ready() -> void:
	load_state()

func save_state() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("metrics", "current_weight", current_weight)
	cfg.set_value("metrics", "total_km", total_km)
	cfg.set_value("metrics", "km_today", km_today)
	cfg.set_value("metrics", "streak", streak)
	cfg.set_value("metrics", "last_log_date", last_log_date)
	cfg.save(SAVE_PATH)

func load_state() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		current_weight = cfg.get_value("metrics", "current_weight", start_weight)
		total_km       = cfg.get_value("metrics", "total_km", 0.0)
		km_today       = cfg.get_value("metrics", "km_today", 0.0)
		streak         = cfg.get_value("metrics", "streak", 0)
		last_log_date  = cfg.get_value("metrics", "last_log_date", "")
	else:
		# First‐run defaults
		current_weight = start_weight
		total_km       = 0.0
		km_today       = 0.0
		streak         = 0
		last_log_date  = ""
