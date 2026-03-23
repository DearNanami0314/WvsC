class_name DamageRule
extends Node

# =========================================================
# 伤害规则 A 版（Day4）
# 规则：玩家受到 X 点伤害 => 强制弃置 X 张手牌（至多弃到 0）
# 说明：仅处理“伤害 -> 弃牌”映射，不处理死亡/胜负判定
# =========================================================


func _ready() -> void:
	Events.player_damage_requested.connect(_on_player_damage_requested)
	Events.player_forced_discard_applied.connect(_on_player_forced_discard_applied)


func _on_player_damage_requested(amount: int, source: String) -> void:
	if amount <= 0:
		print("[DamageRule] 忽略非正伤害: amount=%d, source=%s" % [amount, source])
		return

	var normalized_source := source if not source.is_empty() else "unknown"
	print("[DamageRule] 受理玩家伤害: amount=%d, source=%s" % [amount, normalized_source])
	Events.player_hit.emit()
	Events.player_forced_discard_requested.emit(amount, "damage:%s" % normalized_source)


func _on_player_forced_discard_applied(requested: int, discarded: int, hand_before: int, hand_after: int, reason: String) -> void:
	if not reason.begins_with("damage:"):
		return

	print(
		"[DamageRule] 伤害结算完成: requested=%d, discarded=%d, hand=%d->%d, reason=%s"
		% [requested, discarded, hand_before, hand_after, reason]
	)
