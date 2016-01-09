#encoding:utf-8
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　處理戰鬥者的類。Game_Actor 和 Game_Enemy 類的父類。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 常量（使用效果）
  #--------------------------------------------------------------------------
  EFFECT_RECOVER_HP     = 11              # 恢復 HP
  EFFECT_RECOVER_MP     = 12              # 恢復 MP
  EFFECT_GAIN_TP        = 13              # 增加 TP
  EFFECT_ADD_STATE      = 21              # 附加狀態
  EFFECT_REMOVE_STATE   = 22              # 解除狀態
  EFFECT_ADD_BUFF       = 31              # 強化能力
  EFFECT_ADD_DEBUFF     = 32              # 弱化能力
  EFFECT_REMOVE_BUFF    = 33              # 解除能力強化
  EFFECT_REMOVE_DEBUFF  = 34              # 解除能力弱化
  EFFECT_SPECIAL        = 41              # 特殊效果
  EFFECT_GROW           = 42              # 能力提升
  EFFECT_LEARN_SKILL    = 43              # 學會技能
  EFFECT_COMMON_EVENT   = 44              # 公共事件
  #--------------------------------------------------------------------------
  # ● 常量（特殊效果）
  #--------------------------------------------------------------------------
  SPECIAL_EFFECT_ESCAPE = 0               # 撤退
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :battler_name             # 戰鬥圖像文件名
  attr_reader   :battler_hue              # 戰鬥圖像色相
  attr_reader   :action_times             # 行動回數
  attr_reader   :actions                  # 戰鬥行動（行動方）
  attr_reader   :speed                    # 行動速度
  attr_reader   :result                   # 行動結果（目標方）
  attr_accessor :last_target_index        # 最后目標的索引
  attr_accessor :animation_id             # 動畫 ID
  attr_accessor :animation_mirror         # 動畫左右反轉的標志
  attr_accessor :sprite_effect_type       # 精靈的效果
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @actions = []
    @speed = 0
    @result = Game_ActionResult.new(self)
    @last_target_index = 0
    @guarding = false
    clear_sprite_effects
    super
  end
  #--------------------------------------------------------------------------
  # ● 清除精靈的效果
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @sprite_effect_type = nil
  end
  #--------------------------------------------------------------------------
  # ● 清除戰鬥行動
  #--------------------------------------------------------------------------
  def clear_actions
    @actions.clear
  end
  #--------------------------------------------------------------------------
  # ● 清除狀態信息
  #--------------------------------------------------------------------------
  def clear_states
    super
    @result.clear_status_effects
  end
  #--------------------------------------------------------------------------
  # ● 附加狀態
  #--------------------------------------------------------------------------
  def add_state(state_id)
    if state_addable?(state_id)
      add_new_state(state_id) unless state?(state_id)
      reset_state_counts(state_id)
      @result.added_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定狀態是否可以附加
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    alive? && $data_states[state_id] && !state_resist?(state_id) &&
      !state_removed?(state_id) && !state_restrict?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定狀態是否已被解除
  #--------------------------------------------------------------------------
  def state_removed?(state_id)
    @result.removed_states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定狀態是否受到行動限制影響而無法附加
  #--------------------------------------------------------------------------
  def state_restrict?(state_id)
    $data_states[state_id].remove_by_restriction && restriction > 0
  end
  #--------------------------------------------------------------------------
  # ● 附加新的狀態
  #--------------------------------------------------------------------------
  def add_new_state(state_id)
    die if state_id == death_state_id
    @states.push(state_id)
    on_restrict if restriction > 0
    sort_states
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 行動受到限制時的處理
  #--------------------------------------------------------------------------
  def on_restrict
    clear_actions
    states.each do |state|
      remove_state(state.id) if state.remove_by_restriction
    end
  end
  #--------------------------------------------------------------------------
  # ● 重置狀態計數（回合數或步數）
  #--------------------------------------------------------------------------
  def reset_state_counts(state_id)
    state = $data_states[state_id]
    variance = 1 + [state.max_turns - state.min_turns, 0].max
    @state_turns[state_id] = state.min_turns + rand(variance)
    @state_steps[state_id] = state.steps_to_remove
  end
  #--------------------------------------------------------------------------
  # ● 解除狀態
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    if state?(state_id)
      revive if state_id == death_state_id
      erase_state(state_id)
      refresh
      @result.removed_states.push(state_id).uniq!
    end
  end
  #--------------------------------------------------------------------------
  # ● 死亡
  #--------------------------------------------------------------------------
  def die
    @hp = 0
    clear_states
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # ● 復活
  #--------------------------------------------------------------------------
  def revive
    @hp = 1 if @hp == 0
  end
  #--------------------------------------------------------------------------
  # ● 撤退
  #--------------------------------------------------------------------------
  def escape
    hide if $game_party.in_battle
    clear_actions
    clear_states
    Sound.play_escape
  end
  #--------------------------------------------------------------------------
  # ● 強化能力
  #--------------------------------------------------------------------------
  def add_buff(param_id, turns)
    return unless alive?
    @buffs[param_id] += 1 unless buff_max?(param_id)
    erase_buff(param_id) if debuff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 弱化能力
  #--------------------------------------------------------------------------
  def add_debuff(param_id, turns)
    return unless alive?
    @buffs[param_id] -= 1 unless debuff_max?(param_id)
    erase_buff(param_id) if buff?(param_id)
    overwrite_buff_turns(param_id, turns)
    @result.added_debuffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解除能力強化／弱化狀態
  #--------------------------------------------------------------------------
  def remove_buff(param_id)
    return unless alive?
    return if @buffs[param_id] == 0
    erase_buff(param_id)
    @buff_turns.delete(param_id)
    @result.removed_buffs.push(param_id).uniq!
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 消除能力強化／弱化
  #--------------------------------------------------------------------------
  def erase_buff(param_id)
    @buffs[param_id] = 0
    @buff_turns[param_id] = 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力強化狀態
  #--------------------------------------------------------------------------
  def buff?(param_id)
    @buffs[param_id] > 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化狀態
  #--------------------------------------------------------------------------
  def debuff?(param_id)
    @buffs[param_id] < 0
  end
  #--------------------------------------------------------------------------
  # ● 判定能力強化是否為最大程度
  #--------------------------------------------------------------------------
  def buff_max?(param_id)
    @buffs[param_id] == 2
  end
  #--------------------------------------------------------------------------
  # ● 判定能力弱化是否為最大程度
  #--------------------------------------------------------------------------
  def debuff_max?(param_id)
    @buffs[param_id] == -2
  end
  #--------------------------------------------------------------------------
  # ● 重新設置能力強化／弱化的回合數
  #    如果新的回合數比較短，保持原值。
  #--------------------------------------------------------------------------
  def overwrite_buff_turns(param_id, turns)
    @buff_turns[param_id] = turns if @buff_turns[param_id].to_i < turns
  end
  #--------------------------------------------------------------------------
  # ● 更新狀態的回總數數
  #--------------------------------------------------------------------------
  def update_state_turns
    states.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新強化／弱化的回總數數
  #--------------------------------------------------------------------------
  def update_buff_turns
    @buff_turns.keys.each do |param_id|
      @buff_turns[param_id] -= 1 if @buff_turns[param_id] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除戰鬥狀態
  #--------------------------------------------------------------------------
  def remove_battle_states
    states.each do |state|
      remove_state(state.id) if state.remove_at_battle_end
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除所有的強化／弱化狀態
  #--------------------------------------------------------------------------
  def remove_all_buffs
    @buffs.size.times {|param_id| remove_buff(param_id) }
  end
  #--------------------------------------------------------------------------
  # ● 狀態的自動解除
  #     timing : 時機（1:行動結束 2:回合結束）
  #--------------------------------------------------------------------------
  def remove_states_auto(timing)
    states.each do |state|
      if @state_turns[state.id] == 0 && state.auto_removal_timing == timing
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 強化／弱化的自動解除
  #--------------------------------------------------------------------------
  def remove_buffs_auto
    @buffs.size.times do |param_id|
      next if @buffs[param_id] == 0 || @buff_turns[param_id] > 0
      remove_buff(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 受到傷害時解除狀態
  #--------------------------------------------------------------------------
  def remove_states_by_damage
    states.each do |state|
      if state.remove_by_damage && rand(100) < state.chance_by_damage
        remove_state(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定行動回數
  #--------------------------------------------------------------------------
  def make_action_times
    action_plus_set.inject(1) {|r, p| rand < p ? r + 1 : r }
  end
  #--------------------------------------------------------------------------
  # ● 生成戰鬥行動
  #--------------------------------------------------------------------------
  def make_actions
    clear_actions
    return unless movable?
    @actions = Array.new(make_action_times) { Game_Action.new(self) }
  end
  #--------------------------------------------------------------------------
  # ● 決定行動速度
  #--------------------------------------------------------------------------
  def make_speed
    @speed = @actions.collect {|action| action.speed }.min || 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取當前戰鬥行動
  #--------------------------------------------------------------------------
  def current_action
    @actions[0]
  end
  #--------------------------------------------------------------------------
  # ● 移除當前戰鬥行動
  #--------------------------------------------------------------------------
  def remove_current_action
    @actions.shift
  end
  #--------------------------------------------------------------------------
  # ● 強制戰鬥行動
  #--------------------------------------------------------------------------
  def force_action(skill_id, target_index)
    clear_actions
    action = Game_Action.new(self, true)
    action.set_skill(skill_id)
    if target_index == -2
      action.target_index = last_target_index
    elsif target_index == -1
      action.decide_random_target
    else
      action.target_index = target_index
    end
    @actions.push(action)
  end
  #--------------------------------------------------------------------------
  # ● 計算傷害
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    @result.make_damage(value.to_i, item)
  end
  #--------------------------------------------------------------------------
  # ● 獲取技能／物品的屬性修正值
  #--------------------------------------------------------------------------
  def item_element_rate(user, item)
    if item.damage.element_id < 0
      user.atk_elements.empty? ? 1.0 : elements_max_rate(user.atk_elements)
    else
      element_rate(item.damage.element_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取屬性的最大修正值，返回所有屬性中最有效的一個
  #     elements : 屬性 ID 數組
  #--------------------------------------------------------------------------
  def elements_max_rate(elements)
    elements.inject([0.0]) {|r, i| r.push(element_rate(i)) }.max
  end
  #--------------------------------------------------------------------------
  # ● 應用關鍵一擊
  #--------------------------------------------------------------------------
  def apply_critical(damage)
    damage * 3
  end
  #--------------------------------------------------------------------------
  # ● 應用離散度
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    amp = [damage.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    damage >= 0 ? damage + var : damage - var
  end
  #--------------------------------------------------------------------------
  # ● 應用防御修正
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    damage / (damage > 0 && guard? ? 2 * grd : 1)
  end
  #--------------------------------------------------------------------------
  # ● 處理傷害
  #    調用前需要設置好
  #    @result.hp_damage   @result.mp_damage 
  #    @result.hp_drain    @result.mp_drain
  #--------------------------------------------------------------------------
  def execute_damage(user)
    on_damage(@result.hp_damage) if @result.hp_damage > 0
    self.hp -= @result.hp_damage
    self.mp -= @result.mp_damage
    user.hp += @result.hp_drain
    user.mp += @result.mp_drain
  end
  #--------------------------------------------------------------------------
  # ● 技能／使用物品
  #    對使用目標使用完畢后，應用對于使用目標以外的效果。
  #--------------------------------------------------------------------------
  def use_item(item)
    pay_skill_cost(item) if item.is_a?(RPG::Skill)
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end
  #--------------------------------------------------------------------------
  # ● 消耗物品
  #--------------------------------------------------------------------------
  def consume_item(item)
    $game_party.consume_item(item)
  end
  #--------------------------------------------------------------------------
  # ● 應用對于使用目標以外的效果
  #--------------------------------------------------------------------------
  def item_global_effect_apply(effect)
    if effect.code == EFFECT_COMMON_EVENT
      $game_temp.reserve_common_event(effect.data_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 技能／物品的應用測試
  #    如果使用目標的 HP 或者 MP 全滿時，禁止使用恢復道具。
  #--------------------------------------------------------------------------
  def item_test(user, item)
    return false if item.for_dead_friend? != dead?
    return true if $game_party.in_battle
    return true if item.for_opponent?
    return true if item.damage.recover? && item.damage.to_hp? && hp < mhp
    return true if item.damage.recover? && item.damage.to_mp? && mp < mmp
    return true if item_has_any_valid_effects?(user, item)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定技能／物品是否有效果
  #--------------------------------------------------------------------------
  def item_has_any_valid_effects?(user, item)
    item.effects.any? {|effect| item_effect_test(user, item, effect) }
  end
  #--------------------------------------------------------------------------
  # ● 計算技能／物品的反擊幾率
  #--------------------------------------------------------------------------
  def item_cnt(user, item)
    return 0 unless item.physical?          # 攻擊類型不是物理攻擊
    return 0 unless opposite?(user)         # 隊友無法反擊
    return cnt                              # 返回反擊幾率
  end
  #--------------------------------------------------------------------------
  # ● 計算技能／物品的反射幾率
  #--------------------------------------------------------------------------
  def item_mrf(user, item)
    return mrf if item.magical?             # 是魔法攻擊則返回反射魔法幾率
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 計算技能／物品的成功幾率
  #--------------------------------------------------------------------------
  def item_hit(user, item)
    rate = item.success_rate * 0.01         # 獲取成功幾率
    rate *= user.hit if item.physical?      # 物理攻擊：計算成功幾率的乘積
    return rate                             # 返回計算后的成功幾率
  end
  #--------------------------------------------------------------------------
  # ● 計算技能／物品的閃避幾率
  #--------------------------------------------------------------------------
  def item_eva(user, item)
    return eva if item.physical?            # 是物理攻擊則返回閃避幾率
    return mev if item.magical?             # 是魔法攻擊則返回閃避魔法幾率
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 計算技能／物品的必殺幾率
  #--------------------------------------------------------------------------
  def item_cri(user, item)
    item.damage.critical ? user.cri * (1 - cev) : 0
  end
  #--------------------------------------------------------------------------
  # ● 應用普通攻擊的效果
  #--------------------------------------------------------------------------
  def attack_apply(attacker)
    item_apply(attacker, $data_skills[attacker.attack_skill_id])
  end
  #--------------------------------------------------------------------------
  # ● 應用技能／物品的效果
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    @result.missed = (@result.used && rand >= item_hit(user, item))
    @result.evaded = (!@result.missed && rand < item_eva(user, item))
    if @result.hit?
      unless item.damage.none?
        @result.critical = (rand < item_cri(user, item))
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 測試使用效果
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id])
    else
      true
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用使用效果
  #--------------------------------------------------------------------------
  def item_effect_apply(user, item, effect)
    method_table = {
      EFFECT_RECOVER_HP    => :item_effect_recover_hp,
      EFFECT_RECOVER_MP    => :item_effect_recover_mp,
      EFFECT_GAIN_TP       => :item_effect_gain_tp,
      EFFECT_ADD_STATE     => :item_effect_add_state,
      EFFECT_REMOVE_STATE  => :item_effect_remove_state,
      EFFECT_ADD_BUFF      => :item_effect_add_buff,
      EFFECT_ADD_DEBUFF    => :item_effect_add_debuff,
      EFFECT_REMOVE_BUFF   => :item_effect_remove_buff,
      EFFECT_REMOVE_DEBUFF => :item_effect_remove_debuff,
      EFFECT_SPECIAL       => :item_effect_special,
      EFFECT_GROW          => :item_effect_grow,
      EFFECT_LEARN_SKILL   => :item_effect_learn_skill,
      EFFECT_COMMON_EVENT  => :item_effect_common_event,
    }
    method_name = method_table[effect.code]
    send(method_name, user, item, effect) if method_name
  end
  #--------------------------------------------------------------------------
  # ● 應用“恢復 HP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_hp(user, item, effect)
    value = (mhp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.hp_damage -= value
    @result.success = true
    self.hp += value
  end
  #--------------------------------------------------------------------------
  # ● 應用“恢復 MP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_mp(user, item, effect)
    value = (mmp * effect.value1 + effect.value2) * rec
    value *= user.pha if item.is_a?(RPG::Item)
    value = value.to_i
    @result.mp_damage -= value
    @result.success = true if value != 0
    self.mp += value
  end
  #--------------------------------------------------------------------------
  # ● 應用“增加 TP”效果
  #--------------------------------------------------------------------------
  def item_effect_gain_tp(user, item, effect)
    value = effect.value1.to_i
    @result.tp_damage -= value
    @result.success = true if value != 0
    self.tp += value
  end
  #--------------------------------------------------------------------------
  # ● 應用“附加狀態”效果
  #--------------------------------------------------------------------------
  def item_effect_add_state(user, item, effect)
    if effect.data_id == 0
      item_effect_add_state_attack(user, item, effect)
    else
      item_effect_add_state_normal(user, item, effect)
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“狀態附加”效果：普通攻擊
  #--------------------------------------------------------------------------
  def item_effect_add_state_attack(user, item, effect)
    user.atk_states.each do |state_id|
      chance = effect.value1
      chance *= state_rate(state_id)
      chance *= user.atk_states_rate(state_id)
      chance *= luk_effect_rate(user)
      if rand < chance
        add_state(state_id)
        @result.success = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“狀態附加”效果：普通
  #--------------------------------------------------------------------------
  def item_effect_add_state_normal(user, item, effect)
    chance = effect.value1
    chance *= state_rate(effect.data_id) if opposite?(user)
    chance *= luk_effect_rate(user)      if opposite?(user)
    if rand < chance
      add_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“狀態解除”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    chance = effect.value1
    if rand < chance
      remove_state(effect.data_id)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“強化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_buff(user, item, effect)
    add_buff(effect.data_id, effect.value1)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“弱化能力”效果
  #--------------------------------------------------------------------------
  def item_effect_add_debuff(user, item, effect)
    chance = debuff_rate(effect.data_id) * luk_effect_rate(user)
    if rand < chance
      add_debuff(effect.data_id, effect.value1)
      @result.success = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“解除能力強化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_buff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] > 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“解除能力弱化”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_debuff(user, item, effect)
    remove_buff(effect.data_id) if @buffs[effect.data_id] < 0
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“特殊效果”效果
  #--------------------------------------------------------------------------
  def item_effect_special(user, item, effect)
    case effect.data_id
    when SPECIAL_EFFECT_ESCAPE
      escape
    end
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“能力提升”效果
  #--------------------------------------------------------------------------
  def item_effect_grow(user, item, effect)
    add_param(effect.data_id, effect.value1.to_i)
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“學會技能”效果
  #--------------------------------------------------------------------------
  def item_effect_learn_skill(user, item, effect)
    learn_skill(effect.data_id) if actor?
    @result.success = true
  end
  #--------------------------------------------------------------------------
  # ● 應用“公共事件”效果
  #--------------------------------------------------------------------------
  def item_effect_common_event(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # ● 對技能／物品使用者的效果
  #--------------------------------------------------------------------------
  def item_user_effect(user, item)
    user.tp += item.tp_gain * user.tcr
  end
  #--------------------------------------------------------------------------
  # ● 獲取幸運影響程度
  #--------------------------------------------------------------------------
  def luk_effect_rate(user)
    [1.0 + (user.luk - luk) * 0.001, 0.0].max
  end
  #--------------------------------------------------------------------------
  # ● 判定是否敵對關系
  #--------------------------------------------------------------------------
  def opposite?(battler)
    actor? != battler.actor?
  end
  #--------------------------------------------------------------------------
  # ● 在地圖上受到傷害時的效果
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
  end
  #--------------------------------------------------------------------------
  # ● 初始化目標 TP 
  #--------------------------------------------------------------------------
  def init_tp
    self.tp = rand * 25
  end
  #--------------------------------------------------------------------------
  # ● 清除 TP 
  #--------------------------------------------------------------------------
  def clear_tp
    self.tp = 0
  end
  #--------------------------------------------------------------------------
  # ● 受到傷害時增加的 TP
  #--------------------------------------------------------------------------
  def charge_tp_by_damage(damage_rate)
    self.tp += 50 * damage_rate * tcr
  end
  #--------------------------------------------------------------------------
  # ● HP 自動恢復
  #--------------------------------------------------------------------------
  def regenerate_hp
    damage = -(mhp * hrg).to_i
    perform_map_damage_effect if $game_party.in_battle && damage > 0
    @result.hp_damage = [damage, max_slip_damage].min
    self.hp -= @result.hp_damage
  end
  #--------------------------------------------------------------------------
  # ● 獲取連續傷害最大值
  #--------------------------------------------------------------------------
  def max_slip_damage
    $data_system.opt_slip_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● MP 自動恢復
  #--------------------------------------------------------------------------
  def regenerate_mp
    @result.mp_damage = -(mmp * mrg).to_i
    self.mp -= @result.mp_damage
  end
  #--------------------------------------------------------------------------
  # ● TP 自動恢復
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp += 100 * trg
  end
  #--------------------------------------------------------------------------
  # ● 全部自動恢復
  #--------------------------------------------------------------------------
  def regenerate_all
    if alive?
      regenerate_hp
      regenerate_mp
      regenerate_tp
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥開始處理
  #--------------------------------------------------------------------------
  def on_battle_start
    init_tp unless preserve_tp?
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥行動結束時的處理
  #--------------------------------------------------------------------------
  def on_action_end
    @result.clear
    remove_states_auto(1)
    remove_buffs_auto
  end
  #--------------------------------------------------------------------------
  # ● 回合結束處理
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥結束處理
  #--------------------------------------------------------------------------
  def on_battle_end
    @result.clear
    remove_battle_states
    remove_all_buffs
    clear_actions
    clear_tp unless preserve_tp?
    appear
  end
  #--------------------------------------------------------------------------
  # ● 被傷害時的處理
  #--------------------------------------------------------------------------
  def on_damage(value)
    remove_states_by_damage
    charge_tp_by_damage(value.to_f / mhp)
  end
end
