## 2026-03-18 Task: init
- Day4 targets combat loop: skill resolve, damage rule, defeat rule, enemy AI.

## 2026-03-18 Task: D4-T1 技能结算器骨架接入
- 玩家出牌主流程位于 `Battle/player_controller.gd::_on_play_cards_requested`，在牌型与每回合非单张限制校验后插入结算调用最稳定。
- 事件总线已有 past-tense 风格，新增 `skill_resolve_started / skill_resolved / skill_resolve_finished` 可保持模块解耦，后续规则模块可直接订阅。

## 2026-03-18 Task: D4-T2 A版伤害规则（受伤=弃牌）
- `PlayerController` 持有手牌/牌堆权威操作，强制弃牌应由其通过事件入口执行，避免规则层直接操作 `HandManager`。
- 对“伤害触发弃牌”增加 `requested/applied` 两段事件后，日志链路可稳定追踪：`player_damage_requested -> player_forced_discard_requested -> player_forced_discard_applied`。

## 2026-03-18 Task: D4-T3 失败/胜利判定规则接入
- 通过订阅 `Events.skill_resolved` 可在不耦合出牌/敌人实现细节的前提下，稳定接入“玩家造成伤害 -> 敌方HP下降”的 MVP 规则。
- 胜负规则层与回合编排层都需要 battle-over guard：规则层防重复 emit，`BattleController` 防止结束后继续推进阶段/回合。

## 2026-03-18 Task: D4-T4 建立敌人控制器并接入 Battle 场景
- 在现有 `TurnManager` 已发出 `turn_started(ENEMY)` 的前提下，敌方控制器可仅订阅该事件实现“敌方回合开始 -> 行动 -> 回合结束”的完整闭环。
- 敌方伤害走 `Events.player_damage_requested` 既能复用 `DamageRule`（触发受伤弃牌）也能复用 `DefeatRule`（扣玩家HP）而无需敌方模块直接依赖规则实现。

## 2026-03-18 Task: D4-T5 建立敌方 AI 基类与简单权重 AI
- 将敌方动作决策下沉为 `EnemyAIBase.decide_action(context)` 后，`EnemyController` 仅负责“采集上下文 + 执行动作 + 发事件”，与具体策略解耦。
- MVP 若要求可复现手测结果，权重决策应避免随机数；可用 `turn_index % total_weight` 做确定性“权重区间映射”。
