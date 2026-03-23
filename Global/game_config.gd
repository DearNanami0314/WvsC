class_name GameConfig
extends Resource

# =========================================================
# 全局游戏配置（Resource 形式，可在编辑器 Inspector 中调参）
# 用法：创建 .tres 文件后挂到需要的地方，或通过 Autoload 加载
# =========================================================


# -------------------------
# 牌堆与手牌
# -------------------------
# 每回合抽牌数
@export var cards_per_turn := 5
# 手牌上限（超出则强制弃牌）
@export var max_hand_size := 8
# 初始就绪牌堆大小（开局发多少张牌进牌堆）
@export var starting_deck_size := 40


# -------------------------
# 回合与阶段
# -------------------------
# 每回合允许打出的牌型次数（非单张牌型）
@export var patterns_per_turn := 1
# 单张卡每回合最大打出次数（-1 = 不限）
@export var singles_per_turn := -1


# -------------------------
# 生命系统（A版：受伤 = 弃牌）
# -------------------------
# 就绪牌堆为空时是否判负
@export var lose_on_empty_draw := true


# -------------------------
# 战斗参数
# -------------------------
# 玩家初始护甲
@export var starting_block := 0
# 每回合开始时是否清空护甲
@export var reset_block_each_turn := false
