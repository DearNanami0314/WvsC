class_name PatternTypes
extends RefCounted

# =========================================================
# 牌型枚举（MVP）
# =========================================================

enum Type {
	INVALID,
	SINGLE,
	PAIR,
	THREE_OF_A_KIND,
}


static func to_text(pattern_type: Type) -> String:
	match pattern_type:
		Type.SINGLE:
			return "单张"
		Type.PAIR:
			return "对子"
		Type.THREE_OF_A_KIND:
			return "三条"
		_:
			return "无效牌型"
