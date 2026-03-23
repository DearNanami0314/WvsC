class_name DeckManager
extends Node

# =========================================================
# 牌堆管理器
# 职责：管理"就绪牌堆"和"弃牌堆"，提供统一的抽/弃牌入口
# 对标教程的 CardPile + CharacterStats 中的牌堆逻辑
# =========================================================


# -------------------------
# 牌堆
# -------------------------
# 就绪牌堆（玩家可抽的牌）
var draw_pile: Array = []
# 弃牌堆（已打出的牌）
var discard_pile: Array = []


# =========================================================
# 初始化
# =========================================================

# 初始化牌堆（从牌组复制）
func init_deck(deck_data: Array) -> void:
	# 复制一份，避免修改原始数据
	draw_pile = deck_data.duplicate()
	# 洗牌
	shuffle_draw_pile()
	# 清空弃牌堆
	discard_pile.clear()
	# 广播初始数量
	_update_deck_count()
	print("[DeckManager] 初始化完成：就绪牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])
	Events.append_battle_log("牌堆初始化：抽牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])


# =========================================================
# 抽牌
# =========================================================

# 从就绪牌堆抽一张牌（从顶部抽）
func draw_card():
	# 当前规则：抽牌堆为空则直接抽牌失败（与弃牌堆无关）
	if draw_pile.is_empty():
		print("[DeckManager] 抽牌失败：就绪牌堆为空")
		Events.append_battle_log("抽牌失败：抽牌堆为空")
		Events.draw_failed.emit()
		return null
	
	# 抽牌（从数组头部取出）
	var card = draw_pile.pop_front()
	_update_deck_count()
	print("[DeckManager] 抽1张：就绪牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])
	Events.append_battle_log("抽1张：抽牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])
	Events.card_drawn.emit(card)
	return card


# =========================================================
# 弃牌
# =========================================================

# 将一张牌放入弃牌堆
func discard_card(card, reason: String = "unknown") -> void:
	discard_pile.append(card)
	_update_deck_count()
	print("[DeckManager] 弃1张：就绪牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])
	Events.append_battle_log("弃1张：抽牌堆=%d, 弃牌堆=%d" % [draw_pile.size(), discard_pile.size()])
	Events.card_discarded.emit(card, reason)


# =========================================================
# 洗牌
# =========================================================

# 洗乱就绪牌堆
func shuffle_draw_pile() -> void:
	draw_pile.shuffle()


# 广播牌堆数量变化
func _update_deck_count() -> void:
	Events.deck_count_changed.emit(draw_pile.size(), discard_pile.size())
