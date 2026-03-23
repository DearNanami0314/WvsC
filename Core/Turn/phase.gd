class_name Phase
extends RefCounted

# =========================================================
# 回合阶段枚举
# 定义玩家回合内的所有阶段，以及全局的回合归属（玩家/敌方）
# 对应你的设计文档：
#   开始 → 摸牌 → 自由出牌1 → 牌型打出 → 自由出牌2 → 弃牌 → 结束
# =========================================================


# 当前是谁的回合
enum Side {
	PLAYER,
	ENEMY,
}


# 玩家回合内的阶段流转
enum PlayerPhase {
	TURN_START,       # 回合开始阶段（结算Buff/Debuff）
	DRAW,             # 摸牌阶段
	PLAY,             # 出牌阶段（单张不限；非单张每回合一次）
	DISCARD,          # 弃牌阶段（超出手牌上限则弃牌）
	TURN_END,         # 回合结束阶段（结算回合结束效果）
}


# 阶段流转顺序（按数组索引递进）
const PLAYER_PHASE_ORDER: Array[PlayerPhase] = [
	PlayerPhase.TURN_START,
	PlayerPhase.DRAW,
	PlayerPhase.PLAY,
	PlayerPhase.DISCARD,
	PlayerPhase.TURN_END,
]


# 获取下一个阶段，如果已经是最后一个则返回 -1
static func next_player_phase(current: PlayerPhase) -> int:
	var idx := PLAYER_PHASE_ORDER.find(current)
	if idx < 0 or idx >= PLAYER_PHASE_ORDER.size() - 1:
		return -1
	return PLAYER_PHASE_ORDER[idx + 1]
