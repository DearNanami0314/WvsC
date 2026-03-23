class_name PatternHintUI
extends Label

# =========================================================
# 牌型提示 UI
# 职责：显示当前选牌组成的牌型
# =========================================================


func _ready() -> void:
	text = "当前牌型：无效牌型"
	Events.pattern_updated.connect(_on_pattern_updated)


func _on_pattern_updated(_pattern_type: int, pattern_text: String) -> void:
	text = "当前牌型：%s" % pattern_text
