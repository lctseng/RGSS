#encoding:utf-8
#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　處理戰鬥中的行動的類。本類在 Game_Battler 類的內部使用。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :subject                  # 行動主體
  attr_reader   :forcing                  # 強制行動的標志
  attr_reader   :item                     # 技能 / 物品
  attr_accessor :target_index             # 目標索引
  attr_reader   :value                    # 評價值（自動戰鬥用）
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(subject, forcing = false)
    @subject = subject
    @forcing = forcing
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @item = Game_BaseItem.new
    @target_index = -1
    @value = 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取隊友單位
  #--------------------------------------------------------------------------
  def friends_unit
    subject.friends_unit
  end
  #--------------------------------------------------------------------------
  # ● 獲取敵人單位
  #--------------------------------------------------------------------------
  def opponents_unit
    subject.opponents_unit
  end
  #--------------------------------------------------------------------------
  # ● 設置敵人的戰鬥行動
  #     action : RPG::Enemy::Action
  #--------------------------------------------------------------------------
  def set_enemy_action(action)
    if action
      set_skill(action.skill_id)
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置普通攻擊
  #--------------------------------------------------------------------------
  def set_attack
    set_skill(subject.attack_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 設置防御
  #--------------------------------------------------------------------------
  def set_guard
    set_skill(subject.guard_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 設置技能
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @item.object = $data_skills[skill_id]
    self
  end
  #--------------------------------------------------------------------------
  # ● 設置物品
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @item.object = $data_items[item_id]
    self
  end
  #--------------------------------------------------------------------------
  # ● 獲取物品實例
  #--------------------------------------------------------------------------
  def item
    @item.object
  end
  #--------------------------------------------------------------------------
  # ● 判定是否為普通攻擊
  #--------------------------------------------------------------------------
  def attack?
    item == $data_skills[subject.attack_skill_id]
  end
  #--------------------------------------------------------------------------
  # ● 隨機目標
  #--------------------------------------------------------------------------
  def decide_random_target
    if item.for_dead_friend?
      target = friends_unit.random_dead_target
    elsif item.for_friend?
      target = friends_unit.random_target
    else
      target = opponents_unit.random_target
    end
    if target
      @target_index = target.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置混亂行動
  #--------------------------------------------------------------------------
  def set_confusion
    set_attack
  end
  #--------------------------------------------------------------------------
  # ● 行動準備
  #--------------------------------------------------------------------------
  def prepare
    set_confusion if subject.confusion? && !forcing
  end
  #--------------------------------------------------------------------------
  # ● 判定行動是否有效
  #    假設在事件指令中沒有選擇強制行動時，
  #    受到狀態的限制，也沒有可用的物品，或者沒有預定的行動，則返回 false。
  #--------------------------------------------------------------------------
  def valid?
    (forcing && item) || subject.usable?(item)
  end
  #--------------------------------------------------------------------------
  # ● 計算行動速度
  #--------------------------------------------------------------------------
  def speed
    speed = subject.agi + rand(5 + subject.agi / 4)
    speed += item.speed if item
    speed += subject.atk_speed if attack?
    speed
  end
  #--------------------------------------------------------------------------
  # ● 生成目標數組
  #--------------------------------------------------------------------------
  def make_targets
    if !forcing && subject.confusion?
      [confusion_target]
    elsif item.for_opponent?
      targets_for_opponents
    elsif item.for_friend?
      targets_for_friends
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # ● 混亂時的目標
  #--------------------------------------------------------------------------
  def confusion_target
    case subject.confusion_level
    when 1
      opponents_unit.random_target
    when 2
      if rand(2) == 0
        opponents_unit.random_target
      else
        friends_unit.random_target
      end
    else
      friends_unit.random_target
    end
  end
  #--------------------------------------------------------------------------
  # ● 目標為敵人
  #--------------------------------------------------------------------------
  def targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● 目標為隊友
  #--------------------------------------------------------------------------
  def targets_for_friends
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index)]
      else
        friends_unit.alive_members
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 行動的價值評價（自動戰鬥用）
  #    自動設置 @value 和 @target_index 。
  #--------------------------------------------------------------------------
  def evaluate
    @value = 0
    evaluate_item if valid?
    @value += rand if @value > 0
    self
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的評價
  #--------------------------------------------------------------------------
  def evaluate_item
    item_target_candidates.each do |target|
      value = evaluate_item_with_target(target)
      if item.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取技能／使用物品的候選目標
  #--------------------------------------------------------------------------
  def item_target_candidates
    if item.for_opponent?
      opponents_unit.alive_members
    elsif item.for_user?
      [subject]
    elsif item.for_dead_friend?
      friends_unit.dead_members
    else
      friends_unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的評價（對指定目標）
  #--------------------------------------------------------------------------
  def evaluate_item_with_target(target)
    target.result.clear
    target.make_damage_value(subject, item)
    if item.for_opponent?
      return target.result.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.result.hp_damage, target.mhp - target.hp].min
      return recovery.to_f / target.mhp
    end
  end
end
