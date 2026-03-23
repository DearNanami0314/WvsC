extends Node

const TurnManagerScript := preload("res://Core/Turn/turn_manager.gd")
const PhaseScript := preload("res://Core/Turn/phase.gd")
const EventsScript := preload("res://Global/events.gd")

var _events: Node
var _turn_started_sides: Array[int] = []
var _turn_ended_sides: Array[int] = []
var _phase_history: Array[int] = []


func _ready() -> void:
	print("[test_turn_manager] start")
	
	# 实例化 Events
	_events = EventsScript.new()
	add_child(_events)
	
	# 连接信号
	_events.turn_started.connect(_on_turn_started)
	_events.turn_ended.connect(_on_turn_ended)
	_events.phase_changed.connect(_on_phase_changed)
	
	var manager := TurnManagerScript.new()
	
	manager.start_player_turn()
	assert(manager.current_side == PhaseScript.Side.PLAYER)
	assert(manager.turn_number == 1)
	assert(manager.current_phase == PhaseScript.PlayerPhase.TURN_START)
	assert(_phase_history == [
		PhaseScript.PlayerPhase.TURN_START,
	])
	
	manager.complete_current_phase() # DRAW
	manager.complete_current_phase() # PLAY
	manager.complete_current_phase() # DISCARD
	manager.complete_current_phase() # TURN_END
	
	assert(_phase_history == [
		PhaseScript.PlayerPhase.TURN_START,
		PhaseScript.PlayerPhase.DRAW,
		PhaseScript.PlayerPhase.PLAY,
		PhaseScript.PlayerPhase.DISCARD,
		PhaseScript.PlayerPhase.TURN_END,
	])
	
	manager.complete_current_phase() # 玩家回合结束
	assert(_turn_ended_sides.size() == 1)
	assert(_turn_ended_sides[0] == PhaseScript.Side.PLAYER)
	
	manager.start_enemy_turn()
	assert(manager.current_side == PhaseScript.Side.ENEMY)
	assert(_turn_started_sides == [PhaseScript.Side.PLAYER, PhaseScript.Side.ENEMY])
	
	print("[test_turn_manager] PASS")
	get_tree().quit(0)


func _on_turn_started(side: int) -> void:
	_turn_started_sides.append(side)


func _on_turn_ended(side: int) -> void:
	_turn_ended_sides.append(side)


func _on_phase_changed(phase: int) -> void:
	_phase_history.append(phase)
