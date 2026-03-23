class_name EnemyAIBase
extends RefCounted

# =========================================================
# 敌方 AI 基类（Day4-T5）
# 职责：定义敌方动作决策接口，具体策略由子类实现
# =========================================================

const ACTION_ATTACK := "attack"
const ACTION_DEFEND := "defend"


func decide_action(_context: Dictionary) -> String:
	push_warning("[EnemyAIBase] decide_action() should be overridden by subclass")
	return ACTION_ATTACK
