class_name EnemyController
extends Node

# =========================================================
# 敌方战斗控制器（Day4-T5）
# 职责：在敌方回合开始时调用 AI 做动作决策，执行动作后结束敌方回合
# =========================================================

@export var base_damage: int = 1
@export var action_delay_seconds: float = 0.3
@export var ai_attack_weight: int = 3
@export var ai_defend_weight: int = 1

var _is_acting := false
var _enemy_turn_index := 0
var _ai: RefCounted


func _ready() -> void:
	# 动态加载 AI 类以避免解析时类型问题
	var ai_script := load("res://Battle/ai/simple_weight_ai.gd")
	if ai_script:
		_ai = ai_script.new()
		_ai.attack_weight = ai_attack_weight
		_ai.defend_weight = ai_defend_weight
		print("[EnemyController] AI初始化: type=SimpleWeightAI, attack_weight=%d, defend_weight=%d" % [ai_attack_weight, ai_defend_weight])
	else:
		push_error("[EnemyController] AI脚本加载失败")
		_ai = RefCounted.new()

	Events.turn_started.connect(_on_turn_started)

	# 广播首回合意图（延迟一帧确保 UI 节点就绪）
	call_deferred("_broadcast_initial_intent")


func _broadcast_initial_intent() -> void:
	var context := { "enemy_turn_index": 0, "base_damage": base_damage }
	var action: String = _ai.decide_action(context)
	var value := base_damage if action == "attack" else 0
	Events.enemy_intent_changed.emit(action, value)
	print("[EnemyController] 初始意图广播: %s (%d)" % [action, value])


func _on_turn_started(side) -> void:
	if side != Phase.Side.ENEMY:
		return

	if _is_acting:
		return

	print("[EnemyController] 敌方回合开始")
	Events.append_battle_log("敌方回合开始行动")
	_start_enemy_action()


func _start_enemy_action() -> void:
	_is_acting = true
	await get_tree().create_timer(maxf(action_delay_seconds, 0.0)).timeout

	var context := {
		"enemy_turn_index": _enemy_turn_index,
		"base_damage": base_damage,
	}
	var action: String = _ai.decide_action(context)
	print("[EnemyController] AI动作决策: action=%s, turn_index=%d" % [action, _enemy_turn_index])
	Events.append_battle_log("敌方决策：%s" % action)

	# 广播当前意图（执行前，让 UI 同步显示）
	var intent_value := base_damage if action == "attack" else 0
	Events.enemy_intent_changed.emit(action, intent_value)

	if action == "defend":
		print("[EnemyController] 执行动作：防御（MVP暂不产生数值效果）")
		Events.append_battle_log("敌方执行：防御")
	else:
		var damage := maxi(base_damage, 0)
		print("[EnemyController] 执行动作：对玩家造成伤害 amount=%d" % damage)
		Events.append_battle_log("敌方攻击：造成伤害 %d" % damage)
		Events.player_damage_requested.emit(damage, "enemy_attack")

	Events.enemy_action_completed.emit(self)

	# 预测并广播下回合意图（玩家回合中可见）
	var next_context := {
		"enemy_turn_index": _enemy_turn_index + 1,
		"base_damage": base_damage,
	}
	var next_action: String = _ai.decide_action(next_context)
	var next_value := base_damage if next_action == "attack" else 0
	Events.enemy_intent_changed.emit(next_action, next_value)
	print("[EnemyController] 下回合意图预测: %s (%d)" % [next_action, next_value])

	print("[EnemyController] 敌方回合结束")
	Events.enemy_turn_ended.emit()
	_enemy_turn_index += 1
	_is_acting = false
