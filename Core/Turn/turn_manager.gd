class_name TurnManager
extends Node

# =========================================================
# 回合管理器
# 职责：推进"玩家回合 ↔ 敌方回合"切换，以及玩家回合内的阶段流转
# 编排风格对标教程 battle.gd 的事件驱动方式
# =========================================================


# -------------------------
# 状态
# -------------------------
# 当前是谁的回合
var current_side: Phase.Side = Phase.Side.PLAYER
# 当前玩家回合处于哪个阶段
var current_phase: Phase.PlayerPhase = Phase.PlayerPhase.TURN_START
# 当前回合数（从1开始）
var turn_number := 0

# 每个阶段最短停留时长（秒）
@export var min_phase_duration_seconds: float = 1.0

var _phase_advance_locked := false
var _pending_phase_advance := false
var _phase_lock_timer: SceneTreeTimer


# =========================================================
# 回合切换（供 BattleController 调用）
# =========================================================

# 开始玩家回合
func start_player_turn() -> void:
	current_side = Phase.Side.PLAYER
	turn_number += 1
	current_phase = Phase.PlayerPhase.TURN_START
	_phase_advance_locked = false
	_pending_phase_advance = false
	_phase_lock_timer = null
	print("[TurnManager] === 玩家回合 %d 开始 ===" % turn_number)
	Events.append_battle_log("玩家回合 %d 开始" % turn_number)
	Events.turn_started.emit(current_side)
	# 自动推进到第一个阶段
	advance_phase()


# 开始敌方回合
func start_enemy_turn() -> void:
	current_side = Phase.Side.ENEMY
	_phase_advance_locked = false
	_pending_phase_advance = false
	_phase_lock_timer = null
	print("[TurnManager] === 敌方回合 开始 ===")
	Events.append_battle_log("敌方回合开始")
	Events.turn_started.emit(current_side)


# =========================================================
# 阶段推进（玩家回合内）
# =========================================================

# 推进到下一个阶段
func advance_phase() -> void:
	# 如果不是玩家回合，不处理阶段流转
	if current_side != Phase.Side.PLAYER:
		return

	var phase_name: String = Phase.PlayerPhase.keys()[current_phase]
	print("[TurnManager] 阶段 -> %s" % phase_name)
	Events.append_battle_log("阶段切换：%s" % phase_name)
	_lock_phase_advance_if_needed()
	Events.phase_changed.emit(current_phase)


# 当前阶段完成，推进到下一个
func complete_current_phase() -> void:
	if current_side != Phase.Side.PLAYER:
		return

	if _phase_advance_locked:
		_pending_phase_advance = true
		return

	_perform_phase_advance()


func _perform_phase_advance() -> void:
	var next := Phase.next_player_phase(current_phase)

	if next == -1:
		# 玩家回合所有阶段结束
		_phase_advance_locked = false
		_pending_phase_advance = false
		_phase_lock_timer = null
		print("[TurnManager] === 玩家回合 %d 结束 ===" % turn_number)
		Events.append_battle_log("玩家回合 %d 结束" % turn_number)
		Events.turn_ended.emit(current_side)
		return

	current_phase = next as Phase.PlayerPhase
	advance_phase()


func _lock_phase_advance_if_needed() -> void:
	_phase_advance_locked = false
	_pending_phase_advance = false
	_phase_lock_timer = null

	if min_phase_duration_seconds <= 0.0:
		return

	_phase_advance_locked = true
	_phase_lock_timer = get_tree().create_timer(min_phase_duration_seconds)
	await _phase_lock_timer.timeout
	_phase_advance_locked = false
	_phase_lock_timer = null

	if _pending_phase_advance:
		_pending_phase_advance = false
		_perform_phase_advance()
