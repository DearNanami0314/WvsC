class_name SkillData
extends Resource

# =========================================================
# 技能数据（按牌型驱动伤害）
# =========================================================

const PatternTypesScript = preload("res://Core/Pattern/pattern_types.gd")

@export_group("Skill Attributes")
@export var skill_name: String
@export var pattern_type: PatternTypes.Type = PatternTypesScript.Type.INVALID
@export var base_damage: int = 0
@export_multiline var description: String
