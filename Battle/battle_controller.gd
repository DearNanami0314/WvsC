class_name BattleController
extends Node2D

const DAMAGE_RULE_SCRIPT := preload("res://Core/Rules/damage_rule.gd")
const DEFEAT_RULE_SCRIPT := preload("res://Core/Rules/defeat_rule.gd")

# =========================================================
# 战斗总编排（对标教程 battle.gd）
# 职责：
#   1. 初始化战斗（注入数据、连接信号）
#   2. 驱动"玩家回合 ↔ 敌方回合"循环
#   3. 判定胜负并广播结果
# =========================================================


# -------------------------
# 子节点引用
# -------------------------
@onready var turn_manager: TurnManager = $TurnManager
@onready var player_controller: PlayerController = $PlayerController

var defeat_rule: DefeatRule
var is_battle_over := false


# =========================================================
# 生命周期
# =========================================================

func _ready() -> void:
	# --- 接入规则模块（Day4-T2） ---
	var damage_rule := DAMAGE_RULE_SCRIPT.new()
	add_child(damage_rule)
	# --- 接入规则模块（Day4-T3） ---
	defeat_rule = DEFEAT_RULE_SCRIPT.new()
	add_child(defeat_rule)
	# --- 接入敌方单位显示（Demo 0.2） ---
	var enemy = $Enemy
	if enemy:
		enemy.set_defeat_rule(defeat_rule)

	# --- 连接回合事件 ---
	# 玩家回合结束 → 切到敌方回合
	Events.turn_ended.connect(_on_turn_ended)
	# 敌方回合结束 → 切回玩家回合
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	# 玩家点击结束回合 → 快进阶段到回合结束
	Events.player_turn_ended.connect(_on_player_turn_ended)
	# UI请求推进下一阶段
	Events.phase_advance_requested.connect(_on_phase_advance_requested)
	# 抽牌失败（兜底）：确保无牌可抽必定结算失败
	Events.draw_failed.connect(_on_draw_failed)
	# 胜负已决
	Events.battle_over_screen_requested.connect(_on_battle_over_screen_requested)

	# --- 启动战斗 ---
	start_battle()


# =========================================================
# 战斗流程
# =========================================================

# 手动测试模式：由玩家控制推进，不自动快进
const MANUAL_TEST_MODE := true

func start_battle() -> void:
	print("[BattleController] ====== 战斗开始 ======")
	Events.append_battle_log("====== 战斗开始 ======")
	print("[BattleController] 手动测试说明：")
	print("  推荐使用UI按钮：打出选牌 / 结束出牌阶段 / 弃置选牌")
	print("  键盘保留：E=结束出牌阶段")
	
	# MVP 临时：用测试牌组初始化（后续从 CharacterData 读取）
	var test_deck: Array = []
	for suit in CardData.Suit.values():
		for rank in range(1, 11):
			var card := CardData.new()
			card.suit = suit
			card.rank = rank
			card.id = "%d_%d" % [suit, rank]
			card.display_name = card.get_short_text()
			test_deck.append(card)
	player_controller.init_deck(test_deck)
	
	# 开始第一个玩家回合
	turn_manager.start_player_turn()


# 玩家点击"结束回合"：快进所有剩余阶段直到回合结束
func _on_player_turn_ended() -> void:
	if is_battle_over:
		return

	print("[BattleController] 玩家请求结束出牌阶段")
	Events.append_battle_log("玩家请求结束出牌阶段")
	if turn_manager.current_side == Phase.Side.PLAYER and turn_manager.current_phase == Phase.PlayerPhase.PLAY:
		turn_manager.complete_current_phase()


func _on_phase_advance_requested() -> void:
	if is_battle_over:
		return

	if turn_manager.current_side == Phase.Side.PLAYER:
		turn_manager.complete_current_phase()


func _on_draw_failed() -> void:
	if is_battle_over:
		return

	if defeat_rule:
		Events.append_battle_log("抽牌失败兜底触发失败结算")
		defeat_rule.force_lose("draw_failed_failsafe")


# 某方回合结束
func _on_turn_ended(side) -> void:
	if is_battle_over:
		return

	if side == Phase.Side.PLAYER:
		print("[BattleController] 玩家回合结束 → 进入敌方回合")
		Events.append_battle_log("玩家回合结束，进入敌方回合")
		turn_manager.start_enemy_turn()


# 敌方回合结束 → 开始下一个玩家回合
func _on_enemy_turn_ended() -> void:
	if is_battle_over:
		return

	print("[BattleController] 敌方回合结束 → 进入下一个玩家回合")
	Events.append_battle_log("敌方回合结束，进入玩家回合")
	turn_manager.start_player_turn()


# =========================================================
# 手动测试输入
# =========================================================

func _unhandled_input(event: InputEvent) -> void:
	if is_battle_over:
		return

	if not MANUAL_TEST_MODE:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	# E：结束出牌阶段
	if event.keycode == KEY_E:
		if turn_manager.current_side == Phase.Side.PLAYER and turn_manager.current_phase == Phase.PlayerPhase.PLAY:
			Events.phase_advance_requested.emit()
			return

func _on_battle_over_screen_requested(text: String, type) -> void:
	if is_battle_over:
		return

	is_battle_over = true
	print("[BattleController] 收到战斗结束事件: text=%s, type=%s" % [text, str(type)])
	Events.append_battle_log("战斗结束事件：%s" % text)
