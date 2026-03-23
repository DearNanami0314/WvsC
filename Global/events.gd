extends Node
# =========================================================
# 全局事件总线（Autoload: Events）
# 作用：解耦系统之间的直接引用，让战斗/UI/卡牌通过信号通信
# =========================================================
# -------------------------
# 卡牌交互相关
# -------------------------
# 开始拖拽一张卡（参数：卡牌UI实例）
signal card_drag_started(card_ui)
# 结束拖拽一张卡
signal card_drag_ended(card_ui)
# 进入瞄准状态（如单体目标牌）
signal card_aim_started(card_ui)
# 结束瞄准状态
signal card_aim_ended(card_ui)
# 卡牌已被正式打出（参数：卡牌数据实例）
signal card_played(card)
signal skill_resolve_started(cards: Array, pattern_type: int)
signal skill_resolved(pattern_type: int, skill_name: String, total_damage: int, cards: Array)
signal skill_resolve_finished(cards: Array, pattern_type: int, results: Array)
# 卡牌被选中
signal card_selected(card)
# 卡牌取消选中
signal card_unselected(card)
# 请求打出当前选中的牌组
signal play_cards_requested(cards: Array)
# 请求弃置当前选中的牌组（弃牌阶段）
signal discard_cards_requested(cards: Array)
# 当前选牌组成的牌型变化
signal pattern_updated(pattern_type: int, pattern_text: String)
# 请求显示卡牌提示信息（tooltip）
signal card_tooltip_requested(card)
# 请求隐藏提示信息
signal tooltip_hide_requested
# -------------------------
# 玩家流程相关
# -------------------------
# 玩家本回合抽牌流程完成
signal player_hand_drawn
# 玩家本回合弃牌流程完成
signal player_hand_discarded
# 玩家手牌内容变化（参数：当前手牌数组拷贝）
signal hand_changed(cards: Array)
# 玩家点击“结束回合”
signal player_turn_ended
# 玩家受到伤害（用于红闪、音效等表现）
signal player_hit
# 请求对玩家施加伤害（参数：伤害值，来源标签）
signal player_damage_requested(amount: int, source: String)
# 请求玩家强制弃牌（参数：数量，原因标签）
signal player_forced_discard_requested(amount: int, reason: String)
# 玩家强制弃牌已结算（参数：请求值，实际值，前后手牌，原因）
signal player_forced_discard_applied(requested: int, discarded: int, hand_before: int, hand_after: int, reason: String)
# 玩家死亡
signal player_died

# -------------------------
# 牌堆相关
# -------------------------
# 抽到一张牌（参数：卡牌实例）
signal card_drawn(card)
# 抽牌失败（就绪牌堆为空）
signal draw_failed
# 弃置一张牌（参数：卡牌实例, 原因）
signal card_discarded(card, reason: String)
# 牌堆数量变化（参数：就绪牌堆数量, 弃牌堆数量）
signal deck_count_changed(draw_count: int, discard_count: int)
# -------------------------
# 敌人流程相关
# -------------------------
# 敌方意图变化（参数：动作类型 "attack"/"defend", 数值如伤害量）
signal enemy_intent_changed(action: String, value: int)
# 单个敌人动作执行完成（参数：敌人实例）
signal enemy_action_completed(enemy)
# 敌方整回合执行完成
signal enemy_turn_ended
# -------------------------
# 回合与阶段相关
# -------------------------
# 某方回合开始（参数：Phase.Side 枚举值）
signal turn_started(side)
# 某方回合结束
signal turn_ended(side)
# 玩家回合内阶段切换（参数：Phase.PlayerPhase 枚举值）
signal phase_changed(phase)
# 请求推进到下一阶段（UI按钮触发）
signal phase_advance_requested

# -------------------------
# 战斗结果相关
# -------------------------
# 请求显示战斗结束面板
# text: 显示文案，如 "Victorious!" / "Game Over!"
# type: 面板类型（胜利/失败）
signal battle_over_screen_requested(text: String, type)

# -------------------------
# 日志相关
# -------------------------
# 追加一条战斗日志（用于右下角 Log 面板）
signal battle_log_appended(message: String)


func append_battle_log(message: String) -> void:
	if message.is_empty():
		return
	battle_log_appended.emit(message)
