class_name HandManager
extends Node

# =========================================================
# 手牌管理器
# 职责：管理玩家当前手牌，提供增删/上限检查功能
# 与 UI 层解耦，只处理数据不管表现
# =========================================================


# -------------------------
# 手牌数据
# -------------------------
# 当前手牌列表
var cards: Array = []


# -------------------------
# 引用
# -------------------------
# 牌堆管理器（用于抽牌/弃牌）
var deck_manager: DeckManager


# =========================================================
# 手牌操作
# =========================================================

# 初始化
func setup(deck_mgr: DeckManager) -> void:
	deck_manager = deck_mgr


# 添加一张牌到手牌
func add_card(card) -> void:
	cards.append(card)
	print("[HandManager] 手牌 +1，当前: %d" % cards.size())
	Events.hand_changed.emit(cards.duplicate())


# 从手牌移除一张牌（打出时调用）
func remove_card(card) -> void:
	var idx = cards.find(card)
	if idx >= 0:
		cards.remove_at(idx)
		Events.hand_changed.emit(cards.duplicate())


# 弃置所有手牌（回合结束时）
func discard_all() -> void:
	if cards.is_empty():
		print("[HandManager] 回合结束时无手牌可弃")
		Events.hand_changed.emit(cards.duplicate())
		Events.player_hand_discarded.emit()
		return

	print("[HandManager] 开始弃牌，共 %d 张" % cards.size())
	while not cards.is_empty():
		var card = cards.pop_front()
		deck_manager.discard_card(card)
		Events.hand_changed.emit(cards.duplicate())
	print("[HandManager] 弃牌完成，当前手牌: %d" % cards.size())
	Events.player_hand_discarded.emit()


# 检查是否可添加手牌（未达上限）
func can_add_card() -> bool:
	return true  # MVP 暂不设限，后续可接入 GameConfig.max_hand_size


# 获取手牌数量
func get_card_count() -> int:
	return cards.size()


# 获取所有手牌
func get_cards() -> Array:
	return cards.duplicate()
