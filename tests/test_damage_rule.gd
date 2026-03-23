extends Node

const DamageRuleScript := preload("res://Core/Rules/damage_rule.gd")
const EventsScript := preload("res://Global/events.gd")

var _events: Node
var _hit_count := 0
var _requested_amounts: Array[int] = []
var _requested_reasons: Array[String] = []


func _ready() -> void:
	print("[test_damage_rule] start")
	
	# 实例化 Events
	_events = EventsScript.new()
	add_child(_events)
	
	# 连接信号
	_events.player_hit.connect(_on_player_hit)
	_events.player_forced_discard_requested.connect(_on_forced_discard_requested)
	
	var rule := DamageRuleScript.new()
	
	# 正常伤害：应等量映射到强制弃牌
	rule._on_player_damage_requested(3, "enemy_attack")
	assert(_hit_count == 1)
	assert(_requested_amounts.size() == 1)
	assert(_requested_amounts[0] == 3)
	assert(_requested_reasons[0] == "damage:enemy_attack")
	
	# 空来源：应归一化为 unknown
	rule._on_player_damage_requested(2, "")
	assert(_hit_count == 2)
	assert(_requested_amounts[1] == 2)
	assert(_requested_reasons[1] == "damage:unknown")
	
	# 非正伤害：应被忽略（不新增信号）
	rule._on_player_damage_requested(0, "ignored")
	assert(_hit_count == 2)
	assert(_requested_amounts.size() == 2)
	
	print("[test_damage_rule] PASS")
	get_tree().quit(0)


func _on_player_hit() -> void:
	_hit_count += 1


func _on_forced_discard_requested(amount: int, reason: String) -> void:
	_requested_amounts.append(amount)
	_requested_reasons.append(reason)
