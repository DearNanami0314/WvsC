class_name CardData
extends Resource

# =========================================================
# 卡牌数据（对标教程 custom_resources/card.gd 的写法）
# MVP 先用于 UI 可视化与抽/弃牌流转
# =========================================================

enum Suit {SPADE, HEART, CLUB, DIAMOND}

@export_group("Card Attributes")
@export var id: String
@export var suit: Suit
@export_range(1, 13) var rank := 1
@export var cost := 0

@export_group("Card Visuals")
@export var display_name: String


func get_suit_symbol() -> String:
	match suit:
		Suit.SPADE:
			return "♠"
		Suit.HEART:
			return "♥"
		Suit.CLUB:
			return "♣"
		Suit.DIAMOND:
			return "♦"
		_:
			return "?"


func get_rank_text() -> String:
	match rank:
		1:
			return "A"
		11:
			return "J"
		12:
			return "Q"
		13:
			return "K"
		_:
			return str(rank)


func get_short_text() -> String:
	return "%s%s" % [get_suit_symbol(), get_rank_text()]
