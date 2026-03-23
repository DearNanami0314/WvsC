class_name SkillResolver
extends RefCounted

const PATTERN_TYPES_SCRIPT := preload("res://Core/Pattern/pattern_types.gd")
const SKILL_DATABASE := {
	PATTERN_TYPES_SCRIPT.Type.SINGLE: {"name": "Slash", "damage": 1},
	PATTERN_TYPES_SCRIPT.Type.PAIR: {"name": "Double Strike", "damage": 3},
	PATTERN_TYPES_SCRIPT.Type.THREE_OF_A_KIND: {"name": "Great Bash", "damage": 6},
}


# =========================================================
# 技能结算器（Day4 MVP）
# 职责：接收“合法已打出”的牌组，按稳定顺序逐张结算并广播事件
# 备注：本阶段仅做日志与事件，不做伤害/击杀/AI 等完整战斗规则
# =========================================================


# 批量结算已打出的牌
# 返回值用于后续规则层接入（MVP 先返回稳定结构）
func resolve_played_cards(cards: Array, pattern_type: int) -> Array:
	var results: Array = []
	if cards.is_empty():
		return results

	print("[SkillResolver] 开始结算：数量=%d, 牌型=%s" % [cards.size(), PATTERN_TYPES_SCRIPT.to_text(pattern_type)])
	Events.skill_resolve_started.emit(cards.duplicate(), pattern_type)

	var skill := _get_skill_for_pattern(pattern_type)
	var skill_name: String = skill["name"]
	var total_damage: int = int(skill["damage"])
	var pattern_text := PATTERN_TYPES_SCRIPT.to_text(pattern_type)

	print("[SkillResolver] Detected %s, Triggered %s, Dealing %d Damage" % [pattern_text, skill_name, total_damage])

	var result := {
		"pattern_type": pattern_type,
		"pattern_text": pattern_text,
		"skill_name": skill_name,
		"damage": total_damage,
		"cards": cards.duplicate(),
	}
	results.append(result)

	Events.skill_resolved.emit(pattern_type, skill_name, total_damage, cards.duplicate())

	Events.skill_resolve_finished.emit(cards.duplicate(), pattern_type, results.duplicate(true))
	print("[SkillResolver] 结算完成：数量=%d, 牌型=%s" % [cards.size(), PATTERN_TYPES_SCRIPT.to_text(pattern_type)])
	return results


func _get_skill_for_pattern(pattern_type: int) -> Dictionary:
	if SKILL_DATABASE.has(pattern_type):
		return SKILL_DATABASE[pattern_type]
	return {"name": "Unknown Skill", "damage": 0}
