class_name DefeatRule
extends Node

# =========================================================
# 胜负判定规则 A 版（Day4）
# 规则：
#   - 玩家伤害请求会扣减玩家HP；HP<=0 触发失败
#   - 玩家每次技能结算会按技能总伤害扣减敌方HP；HP<=0 触发胜利
# 说明：
#   - 仅负责“HP状态 -> 战斗结束事件”
#   - 使用 battle_over 锁避免重复触发
# =========================================================


enum BattleResultType { WIN, LOSE }

@export var initial_player_hp: int = 10
@export var initial_enemy_hp: int = 10

var player_hp: int = 0
var enemy_hp: int = 0
var battle_over: bool = false


func _ready() -> void:
	player_hp = maxi(initial_player_hp, 1)
	enemy_hp = maxi(initial_enemy_hp, 1)

	Events.player_damage_requested.connect(_on_player_damage_requested)
	Events.skill_resolved.connect(_on_skill_resolved)
	Events.draw_failed.connect(_on_draw_failed)

	print("[DefeatRule] 初始化: player_hp=%d, enemy_hp=%d" % [player_hp, enemy_hp])
	Events.append_battle_log("战斗初始化：玩家HP=%d，敌方HP=%d" % [player_hp, enemy_hp])


func is_battle_over() -> bool:
	return battle_over


func _on_player_damage_requested(amount: int, source: String) -> void:
	if battle_over:
		return

	if amount <= 0:
		print("[DefeatRule] 忽略非正玩家伤害: amount=%d, source=%s" % [amount, source])
		return

	var normalized_source := source if not source.is_empty() else "unknown"
	var before_hp := player_hp
	player_hp = maxi(player_hp - amount, 0)

	print(
		"[DefeatRule] 玩家受伤: -%d HP, %d -> %d, source=%s"
		% [amount, before_hp, player_hp, normalized_source]
	)
	Events.append_battle_log("玩家受伤：-%d HP（%d→%d）" % [amount, before_hp, player_hp])

	if player_hp <= 0:
		_emit_lose_once()


func _on_skill_resolved(pattern_type: int, skill_name: String, total_damage: int, cards: Array) -> void:
	if battle_over:
		return

	if total_damage <= 0:
		print("[DefeatRule] 忽略非正技能伤害: damage=%d, skill=%s, pattern=%d" % [total_damage, skill_name, pattern_type])
		return

	var damage := total_damage
	var before_hp := enemy_hp
	enemy_hp = maxi(enemy_hp - damage, 0)

	print(
		"[DefeatRule] 敌方受击: -%d HP, %d -> %d, skill=%s, pattern=%d, cards=%d"
		% [damage, before_hp, enemy_hp, skill_name, pattern_type, cards.size()]
	)
	Events.append_battle_log("敌方受击：-%d HP（%d→%d）" % [damage, before_hp, enemy_hp])

	if enemy_hp <= 0:
		_emit_win_once()


func _on_draw_failed() -> void:
	force_lose("draw_failed")


func force_lose(reason: String = "unknown") -> void:
	if battle_over:
		return

	print("[DefeatRule] 触发失败：reason=%s" % reason)
	Events.append_battle_log("战斗失败触发：%s" % reason)
	_emit_lose_once()


func _emit_win_once() -> void:
	if battle_over:
		return
	battle_over = true
	print("[DefeatRule] 战斗结束：胜利")
	Events.append_battle_log("战斗结束：胜利")
	Events.battle_over_screen_requested.emit("Victorious!", BattleResultType.WIN)


func _emit_lose_once() -> void:
	if battle_over:
		return
	battle_over = true
	print("[DefeatRule] 战斗结束：失败")
	Events.append_battle_log("战斗结束：失败")
	Events.player_died.emit()
	Events.battle_over_screen_requested.emit("Game Over!", BattleResultType.LOSE)
