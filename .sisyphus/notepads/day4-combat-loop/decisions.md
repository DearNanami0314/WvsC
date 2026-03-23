## 2026-03-18 Task: init
- Follow tutorial-style event-driven architecture and keep MVP rules explicit.

## 2026-03-18 Task: D4-T1 技能结算器骨架接入
- 新建 `res://Core/Resolver/skill_resolver.gd` 作为独立结算类（`RefCounted`），公开 `resolve_played_cards(cards, pattern_type)` 作为 Day4 MVP API。
- 结算顺序采用“输入顺序逐张处理”并返回稳定结果结构（card/pattern_type/order/total），确保日志与行为可预测。
- 在 `PlayerController` 中先结算后进入已有逐张 `play_card` 弃牌流程，不改动 Day3 的“非单张每回合一次”规则语义。

## 2026-03-18 Task: D4-T2 A版伤害规则（受伤=弃牌）
- 新建 `Core/Rules/damage_rule.gd` 作为独立规则模块，只负责把伤害请求映射为强制弃牌请求，不处理胜负/死亡逻辑。
- 通过 `BattleController` 在战斗启动时挂载 `DamageRule` 节点，避免对场景文件做额外结构修改，并保持规则模块可插拔。
- 强制弃牌实际执行仍放在 `PlayerController`，以“手牌当前顺序前 N 张”为确定性弃牌策略，数量上限取 `min(伤害值, 当前手牌数)`。

## 2026-03-18 Task: D4-T3 失败/胜利判定规则接入
- 新建 `Core/Rules/defeat_rule.gd` 独立维护 `player_hp/enemy_hp`（默认各 10）并只通过 Events 总线对外广播结果，保持规则解耦可替换。
- MVP 伤害映射确定为：`player_damage_requested(amount)` 扣玩家 HP；`skill_resolved` 每张牌固定造成 1 点敌方伤害，保证可预测、可手测。
- 战斗结束统一以 `battle_over_screen_requested("Victorious!"/"Game Over!", type)` 作为终点事件，并在 `BattleController` 增加终局锁防止继续推进回合。

## 2026-03-18 Task: D4-T4 建立敌人控制器并接入 Battle 场景
- 新建 `Battle/enemy_controller.gd` 作为敌方行动唯一入口：监听 `turn_started`，仅在 `Phase.Side.ENEMY` 时执行一次固定伤害动作并发送 `enemy_turn_ended`。
- 从 `BattleController` 移除临时 `_simulate_enemy_turn/_apply_test_enemy_damage`，保持战斗编排层只负责“切回合”，把敌方行为下沉到专用控制器。
- 将 `EnemyController` 作为 `Battle` 场景子节点接入，MVP 固定伤害来源标记为 `enemy_attack`，确保后续日志与规则链路可追踪。

## 2026-03-18 Task: D4-T5 建立敌方 AI 基类与简单权重 AI
- 新建 `Battle/ai/enemy_ai_base.gd` 统一定义 `attack/defend` 动作常量与 `decide_action(context)` 虚接口，作为后续 AI 策略扩展点。
- 采用 `Battle/ai/simple_weight_ai.gd` 的确定性权重策略：`bucket = turn_index % (attack_weight + defend_weight)`，落入攻击区间则攻击，否则防御。
- `EnemyController` 默认注入 `SimpleWeightAI` 并把权重配置暴露为导出字段；AI 仅决定“做什么”，具体效果仍由控制器通过 Events 触发。
