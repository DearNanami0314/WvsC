## TODOs

- [x] D4-T1 建立技能结算器骨架（`core/resolver/skill_resolver.gd`）并接入玩家出牌主流程
- [x] D4-T2 建立 A 版伤害规则（`core/rules/damage_rule.gd`）：受伤=弃牌
- [x] D4-T3 建立失败/胜利判定规则（`core/rules/defeat_rule.gd`）并接入回合循环
- [x] D4-T4 建立敌人控制器（`battle/enemy_controller.gd`）并接入 Battle 场景
- [x] D4-T5 建立敌方 AI 基类与简单权重 AI（`battle/ai/enemy_ai_base.gd`、`simple_weight_ai.gd`）
- [x] D4-T6 完成日终验收：玩家打牌有效果、敌人会行动、受伤触发弃牌、可胜负

## Final Verification Wave

- [x] F1 构建与类型检查通过
- [ ] F2 交互流程手测通过（完整回合闭环）
- [x] F3 规则正确性审查通过（伤害/弃牌/胜负）
- [x] F4 代码结构与教程风格一致性审查通过
