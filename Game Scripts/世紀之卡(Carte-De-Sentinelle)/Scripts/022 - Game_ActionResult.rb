#encoding:utf-8
#==============================================================================
# ■ Game_ActionResult
#------------------------------------------------------------------------------
# 　戰鬥行動結果的管理類。本類在 Game_Battler 類的內部使用。
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :used                     # 使用的標志
  attr_accessor :missed                   # 命中失敗的標志
  attr_accessor :evaded                   # 回避成功的標志
  attr_accessor :critical                 # 關鍵一擊的標志
  attr_accessor :success                  # 成功的標志
  attr_accessor :hp_damage                # HP 傷害
  attr_accessor :mp_damage                # MP 傷害
  attr_accessor :tp_damage                # TP 傷害
  attr_accessor :hp_drain                 # HP 吸收
  attr_accessor :mp_drain                 # MP 吸收
  attr_accessor :added_states             # 被附加的狀態
  attr_accessor :removed_states           # 被解除的狀態
  attr_accessor :added_buffs              # 被附加的能力強化
  attr_accessor :added_debuffs            # 被附加的能力弱化
  attr_accessor :removed_buffs            # 被解除的強化／弱化
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    clear_hit_flags
    clear_damage_values
    clear_status_effects
  end
  #--------------------------------------------------------------------------
  # ● 清除命中的標志
  #--------------------------------------------------------------------------
  def clear_hit_flags
    @used = false
    @missed = false
    @evaded = false
    @critical = false
    @success = false
  end
  #--------------------------------------------------------------------------
  # ● 清除傷害值
  #--------------------------------------------------------------------------
  def clear_damage_values
    @hp_damage = 0
    @mp_damage = 0
    @tp_damage = 0
    @hp_drain = 0
    @mp_drain = 0
  end
  #--------------------------------------------------------------------------
  # ● 生成傷害
  #--------------------------------------------------------------------------
  def make_damage(value, item)
    @critical = false if value == 0
    @hp_damage = value if item.damage.to_hp?
    @mp_damage = value if item.damage.to_mp?
    @mp_damage = [@battler.mp, @mp_damage].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
    @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  #--------------------------------------------------------------------------
  # ● 清除狀態效果
  #--------------------------------------------------------------------------
  def clear_status_effects
    @added_states = []
    @removed_states = []
    @added_buffs = []
    @added_debuffs = []
    @removed_buffs = []
  end
  #--------------------------------------------------------------------------
  # ● 獲取被附加的狀態的實例數組
  #--------------------------------------------------------------------------
  def added_state_objects
    @added_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ● 獲取被解除的狀態的實例數組
  #--------------------------------------------------------------------------
  def removed_state_objects
    @removed_states.collect {|id| $data_states[id] }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否受到任何狀態的影響
  #--------------------------------------------------------------------------
  def status_affected?
    !(@added_states.empty? && @removed_states.empty? &&
      @added_buffs.empty? && @added_debuffs.empty? && @removed_buffs.empty?)
  end
  #--------------------------------------------------------------------------
  # ● 判定最后是否命中
  #--------------------------------------------------------------------------
  def hit?
    @used && !@missed && !@evaded
  end
  #--------------------------------------------------------------------------
  # ● 獲取 HP 傷害的文字
  #--------------------------------------------------------------------------
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::hp, @hp_drain)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
    else
      fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      sprintf(fmt, @battler.name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取 MP 傷害的文字
  #--------------------------------------------------------------------------
  def mp_damage_text
    if @mp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::mp, @mp_drain)
    elsif @mp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::mp, @mp_damage)
    elsif @mp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::mp, -@mp_damage)
    else
      ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取 TP 傷害的文字
  #--------------------------------------------------------------------------
  def tp_damage_text
    if @tp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      sprintf(fmt, @battler.name, Vocab::tp, @tp_damage)
    elsif @tp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorGain : Vocab::EnemyGain
      sprintf(fmt, @battler.name, Vocab::tp, -@tp_damage)
    else
      ""
    end
  end
end
