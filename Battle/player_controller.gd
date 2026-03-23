class_name PlayerController
extends Node

const PATTERN_ENGINE_SCRIPT := preload("res://Core/Pattern/pattern_engine.gd")
const SKILL_RESOLVER_SCRIPT := preload("res://Core/Resolver/skill_resolver.gd")

# =========================================================
# 玩家战斗控制器
# 职责：管理玩家在战斗中的行为（抽牌/出牌/弃牌）
# 对标教程的 PlayerHandler
# =========================================================


# -------------------------
# 子系统
# -------------------------
var deck_manager: DeckManager
var hand_manager: HandManager
var pattern_engine = PATTERN_ENGINE_SCRIPT.new()
var skill_resolver = SKILL_RESOLVER_SCRIPT.new()
var current_phase: int = Phase.PlayerPhase.TURN_START
var non_single_used_this_turn := false


# -------------------------
# 配置
# -------------------------
# 每回合抽牌数（从 GameConfig 读取）
var cards_per_turn: int = 5
var max_hand_size: int = 8


# =========================================================
# 初始化
# =========================================================

func _ready() -> void:
	# 创建子系统的实例
	deck_manager = DeckManager.new()
	hand_manager = HandManager.new()
	hand_manager.setup(deck_manager)
	
	# 添加为子节点（这样它们会在场景中）
	add_child(deck_manager)
	add_child(hand_manager)
	
	# 连接阶段变化 → 在 DRAW 阶段抽牌
	Events.phase_changed.connect(_on_phase_changed)
	# 连接“打出选中牌组”请求
	Events.play_cards_requested.connect(_on_play_cards_requested)
	# 连接“弃置选中牌组”请求
	Events.discard_cards_requested.connect(_on_discard_cards_requested)
	# 连接“强制弃牌”请求（如受伤）
	Events.player_forced_discard_requested.connect(_on_player_forced_discard_requested)


# 初始化玩家牌组（战斗开始时调用）
func init_deck(deck_data: Array) -> void:
	deck_manager.init_deck(deck_data)
	print("[PlayerController] 初始化牌组完成，数量: %d" % deck_data.size())


# =========================================================
# 回合流程
# =========================================================

# 阶段变化时检查是否需要抽牌
func _on_phase_changed(phase) -> void:
	current_phase = phase

	if phase == Phase.PlayerPhase.TURN_START:
		non_single_used_this_turn = false
		Events.phase_advance_requested.emit()
		return

	if phase == Phase.PlayerPhase.DRAW:
		print("[PlayerController] 进入 DRAW 阶段，每回合固定抽 %d 张" % cards_per_turn)
		Events.append_battle_log("玩家进入抽牌阶段（固定抽%d）" % cards_per_turn)
		draw_cards(cards_per_turn)
		Events.phase_advance_requested.emit()
		return

	if phase == Phase.PlayerPhase.PLAY:
		print("[PlayerController] 进入出牌阶段（单张不限，非单张仅一次）")
		Events.append_battle_log("玩家进入出牌阶段")
		return

	if phase == Phase.PlayerPhase.DISCARD:
		print("[PlayerController] 进入弃牌阶段，当前手牌=%d，上限=%d" % [hand_manager.get_card_count(), max_hand_size])
		Events.append_battle_log("玩家进入弃牌阶段：手牌=%d/%d" % [hand_manager.get_card_count(), max_hand_size])
		if hand_manager.get_card_count() <= max_hand_size:
			print("[PlayerController] 无需弃牌，自动结束回合")
			Events.append_battle_log("无需弃牌，自动结束回合")
			Events.phase_advance_requested.emit()
		return

	if phase == Phase.PlayerPhase.TURN_END:
		Events.phase_advance_requested.emit()


# =========================================================
# 抽牌
# =========================================================

# 抽 N 张牌（MVP阶段同步抽牌，避免与自动阶段推进冲突）
func draw_cards(amount: int) -> void:
	for i in range(amount):
		var card = deck_manager.draw_card()
		if card == null:
			print("[PlayerController] 抽牌中断：无牌可抽")
			Events.append_battle_log("抽牌中断：无牌可抽")
			return

		hand_manager.add_card(card)

	print("[PlayerController] 抽牌阶段完成，当前手牌: %d" % hand_manager.get_card_count())
	Events.append_battle_log("抽牌完成：当前手牌=%d" % hand_manager.get_card_count())
	Events.player_hand_drawn.emit()


# =========================================================
# 出牌（MVP 临时空实现，后续补）
# =========================================================

# 尝试打出一张牌
func play_card(card) -> bool:
	# 检查手牌中是否有这张牌
	if not card in hand_manager.get_cards():
		return false
	
	# 从手牌移除
	hand_manager.remove_card(card)
	# 放入弃牌堆
	deck_manager.discard_card(card, "played")
	# 广播出牌事件
	Events.card_played.emit(card)
	return true


# 打出当前选中的牌组（Day3）
func _on_play_cards_requested(cards: Array) -> void:
	if current_phase != Phase.PlayerPhase.PLAY:
		print("[PlayerController] 当前不在出牌阶段")
		return

	if cards.is_empty():
		return

	var pattern_type: int = pattern_engine.detect(cards)
	if pattern_type == PatternTypes.Type.INVALID:
		print("[PlayerController] 非法牌型，无法打出")
		return

	if pattern_type != PatternTypes.Type.SINGLE:
		if non_single_used_this_turn:
			print("[PlayerController] 本回合非单张牌型已使用过一次")
			return
		non_single_used_this_turn = true

	# MVP：逐张打出（后续可按牌型统一结算）
	skill_resolver.resolve_played_cards(cards, pattern_type)

	for c in cards:
		play_card(c)

	print("[PlayerController] 已打出 %d 张，牌型=%s" % [cards.size(), PatternTypes.to_text(pattern_type)])


func _on_discard_cards_requested(cards: Array) -> void:
	if current_phase != Phase.PlayerPhase.DISCARD:
		print("[PlayerController] 当前不在弃牌阶段")
		return

	if cards.is_empty():
		return

	for c in cards:
		if c in hand_manager.get_cards():
			hand_manager.remove_card(c)
			deck_manager.discard_card(c, "discard_phase")

	var hand_count := hand_manager.get_card_count()
	print("[PlayerController] 弃牌后手牌=%d, 上限=%d" % [hand_count, max_hand_size])
	if hand_count <= max_hand_size:
		print("[PlayerController] 弃牌完成，自动结束回合")
		Events.phase_advance_requested.emit()


func _on_player_forced_discard_requested(amount: int, reason: String) -> void:
	var requested := maxi(amount, 0)
	var hand_before := hand_manager.get_card_count()

	if requested <= 0:
		print("[PlayerController] 强制弃牌忽略：非正数量 amount=%d, reason=%s" % [amount, reason])
		Events.player_forced_discard_applied.emit(requested, 0, hand_before, hand_before, reason)
		return

	if hand_before <= 0:
		print("[PlayerController] 强制弃牌：当前无手牌可弃，requested=%d, reason=%s" % [requested, reason])
		Events.player_forced_discard_applied.emit(requested, 0, hand_before, hand_before, reason)
		return

	var cards_snapshot := hand_manager.get_cards()
	var discard_count := mini(requested, cards_snapshot.size())
	for i in range(discard_count):
		var card = cards_snapshot[i]
		hand_manager.remove_card(card)
		deck_manager.discard_card(card, reason)

	var hand_after := hand_manager.get_card_count()
	print(
		"[PlayerController] 强制弃牌完成: requested=%d, discarded=%d, hand=%d->%d, reason=%s"
		% [requested, discard_count, hand_before, hand_after, reason]
	)
	Events.player_forced_discard_applied.emit(requested, discard_count, hand_before, hand_after, reason)
