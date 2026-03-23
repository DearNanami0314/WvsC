class_name PatternEngine
extends RefCounted

# =========================================================
# 牌型识别引擎（MVP）
# 仅支持：单张 / 对子 / 三条
# =========================================================


func detect(cards: Array) -> PatternTypes.Type:
	if cards.is_empty():
		return PatternTypes.Type.INVALID

	match cards.size():
		1:
			return PatternTypes.Type.SINGLE
		2:
			if _is_same_rank(cards):
				return PatternTypes.Type.PAIR
			return PatternTypes.Type.INVALID
		3:
			if _is_same_rank(cards):
				return PatternTypes.Type.THREE_OF_A_KIND
			return PatternTypes.Type.INVALID
		_:
			return PatternTypes.Type.INVALID


func _is_same_rank(cards: Array) -> bool:
	if cards.is_empty():
		return false

	var first_card := cards[0] as CardData
	if not first_card:
		return false

	for c in cards:
		var card := c as CardData
		if not card or card.rank != first_card.rank:
			return false

	return true
