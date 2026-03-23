class_name SimpleWeightAI
extends RefCounted

# =========================================================
# 简单权重 AI（Day4-T5 MVP）
# 职责：在 attack / defend 两种动作间做确定性选择
# 规则：按 turn_index 映射到权重区间，不使用随机数，保证可复现
# =========================================================

const ACTION_ATTACK := "attack"
const ACTION_DEFEND := "defend"

var attack_weight: int = 3
var defend_weight: int = 1


func decide_action(context: Dictionary) -> String:
	var attack := maxi(attack_weight, 0)
	var defend := maxi(defend_weight, 0)
	var total := attack + defend

	if total <= 0:
		print("[SimpleWeightAI] 权重均为0，回退 attack")
		return ACTION_ATTACK

	var turn_index: int = int(context.get("enemy_turn_index", 0))
	var bucket := posmod(turn_index, total)
	var action := ACTION_ATTACK if bucket < attack else ACTION_DEFEND

	print("[SimpleWeightAI] 决策 action=%s, turn_index=%d, attack_weight=%d, defend_weight=%d, bucket=%d/%d" % [
		action,
		turn_index,
		attack,
		defend,
		bucket,
		total
	])

	return action
