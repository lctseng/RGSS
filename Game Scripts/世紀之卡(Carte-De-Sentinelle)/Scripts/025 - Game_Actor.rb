#encoding:utf-8
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　管理角色的類。
#   本類在 Game_Actors 類 ($game_actors) 的內部使用。
#   具體使用請查看 Game_Party 類 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :name                     # 名字
  attr_accessor :nickname                 # 稱號
  attr_reader   :character_name           # 行走圖文件名
  attr_reader   :character_index          # 行走圖索引
  attr_reader   :face_name                # 肖像文件名
  attr_reader   :face_index               # 肖像索引
  attr_reader   :class_id                 # 職業 ID
  attr_reader   :level                    # 等級
  attr_reader   :action_input_index       # 輸入中的戰鬥行動編號
  attr_reader   :last_skill               # 光標記憶用 : 技能
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill = Game_BaseItem.new
  end
  #--------------------------------------------------------------------------
  # ● 設置
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor_id = actor_id
    @name = actor.name
    @nickname = actor.nickname
    init_graphics
    @class_id = actor.class_id
    @level = actor.initial_level
    @exp = {}
    @equips = []
    init_exp
    init_skills
    init_equips(actor.equips)
    clear_param_plus
    recover_all
  end
  #--------------------------------------------------------------------------
  # ● 獲取角色實例
  #--------------------------------------------------------------------------
  def actor
    $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # ● 初始化圖像
  #--------------------------------------------------------------------------
  def init_graphics
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
  end
  #--------------------------------------------------------------------------
  # ● 達到指定等級需要累積的經驗值
  #--------------------------------------------------------------------------
  def exp_for_level(level)
    self.class.exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # ● 初始化經驗值
  #--------------------------------------------------------------------------
  def init_exp
    @exp[@class_id] = current_level_exp
  end
  #--------------------------------------------------------------------------
  # ● 獲取經驗值
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 獲取當前等級的最低經驗值
  #--------------------------------------------------------------------------
  def current_level_exp
    exp_for_level(@level)
  end
  #--------------------------------------------------------------------------
  # ● 獲取下一個等級的經驗值
  #--------------------------------------------------------------------------
  def next_level_exp
    exp_for_level(@level + 1)
  end
  #--------------------------------------------------------------------------
  # ● 最大等級
  #--------------------------------------------------------------------------
  def max_level
    actor.max_level
  end
  #--------------------------------------------------------------------------
  # ● 判定是否達到最大等級
  #--------------------------------------------------------------------------
  def max_level?
    @level >= max_level
  end
  #--------------------------------------------------------------------------
  # ● 初始化技能
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
  end
  #--------------------------------------------------------------------------
  # ● 初始化裝備
  #     equips : 初期裝備的數組
  #--------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(equip_slots.size) { Game_BaseItem.new }
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 將索引變換為裝備類型
  #--------------------------------------------------------------------------
  def index_to_etype_id(index)
    index == 1 && dual_wield? ? 0 : index
  end
  #--------------------------------------------------------------------------
  # ● 將裝備類型變換為裝備欄 ID 的列表
  #--------------------------------------------------------------------------
  def slot_list(etype_id)
    result = []
    equip_slots.each_with_index {|e, i| result.push(i) if e == etype_id }
    result
  end
  #--------------------------------------------------------------------------
  # ● 將裝備類型變換為裝備欄 ID（優先返回空的裝備欄）
  #--------------------------------------------------------------------------
  def empty_slot(etype_id)
    list = slot_list(etype_id)
    list.find {|i| @equips[i].is_nil? } || list[0]
  end
  #--------------------------------------------------------------------------
  # ● 獲取裝備欄的數組
  #--------------------------------------------------------------------------
  def equip_slots
    return [0,0,2,3,4] if dual_wield?       # 雙持武器
    return [0,1,2,3,4]                      # 普通
  end
  #--------------------------------------------------------------------------
  # ● 獲取武器實例的數組
  #--------------------------------------------------------------------------
  def weapons
    @equips.select {|item| item.is_weapon? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 獲取護甲實例的數組
  #--------------------------------------------------------------------------
  def armors
    @equips.select {|item| item.is_armor? }.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 獲取裝備實例的數組
  #--------------------------------------------------------------------------
  def equips
    @equips.collect {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以更換裝備
  #     slot_id : 裝備欄 ID
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更換裝備
  #     slot_id : 裝備欄 ID
  #     item    : 武器／護甲（為 nil 時裝備解除）
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 強制更換裝備
  #     slot_id : 裝備欄 ID
  #     item    : 武器／護甲（為 nil 時裝備解除）
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    @equips[slot_id].object = item
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 交換物品
  #     new_item : 取出的物品
  #     old_item : 放入的物品
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更換裝備（用 ID 指定）
  #     slot_id : 裝備欄 ID
  #     item_id : 武器／護甲 ID
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    if equip_slots[slot_id] == 0
      change_equip(slot_id, $data_weapons[item_id])
    else
      change_equip(slot_id, $data_armors[item_id])
    end
  end
  #--------------------------------------------------------------------------
  # ● 丟棄裝備
  #     item : 丟棄的武器／護甲
  #--------------------------------------------------------------------------
  def discard_equip(item)
    slot_id = equips.index(item)
    @equips[slot_id].object = nil if slot_id
  end
  #--------------------------------------------------------------------------
  # ● 卸下無法裝備的物品
  #     item_gain : 卸下的裝備是否保留
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    @equips.each_with_index do |item, i|
      if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
        trade_item_with_party(nil, item.object) if item_gain
        item.object = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 卸下全部裝備
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 裝備上最強裝備
  #--------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game_party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否裝備技能所需要的所有必要武器裝備
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    return true if wtype_id1 == 0 && wtype_id2 == 0
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 是否裝備著特定類型的武器裝備
  #--------------------------------------------------------------------------
  def wtype_equipped?(wtype_id)
    weapons.any? {|weapon| weapon.wtype_id == wtype_id }
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    release_unequippable_items
    super
  end
  #--------------------------------------------------------------------------
  # ● 判定是否隊友
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 獲取隊友單位
  #--------------------------------------------------------------------------
  def friends_unit
    $game_party
  end
  #--------------------------------------------------------------------------
  # ● 獲取敵人單位
  #--------------------------------------------------------------------------
  def opponents_unit
    $game_troop
  end
  #--------------------------------------------------------------------------
  # ● 獲取角色 ID 
  #--------------------------------------------------------------------------
  def id
    @actor_id
  end
  #--------------------------------------------------------------------------
  # ● 索引
  #--------------------------------------------------------------------------
  def index
    $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # ● 參戰角色判定
  #--------------------------------------------------------------------------
  def battle_member?
    $game_party.battle_members.include?(self)
  end
  #--------------------------------------------------------------------------
  # ● 獲取職業實例
  #--------------------------------------------------------------------------
  def class
    $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 獲取技能實例的數組
  #--------------------------------------------------------------------------
  def skills
    (@skills | added_skills).sort.collect {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ● 獲取當前可用的技能的數組
  #--------------------------------------------------------------------------
  def usable_skills
    skills.select {|skill| usable?(skill) }
  end
  #--------------------------------------------------------------------------
  # ● 以數組方式獲取擁有特性所有實例
  #--------------------------------------------------------------------------
  def feature_objects
    super + [actor] + [self.class] + equips.compact
  end
  #--------------------------------------------------------------------------
  # ● 獲取攻擊屬性
  #--------------------------------------------------------------------------
  def atk_elements
    set = super
    set |= [1] if weapons.compact.empty?  # 空手：物理屬性
    return set
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通能力的最大值
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 9999 if param_id == 0  # MHP
    return super
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通能力的基礎值
  #--------------------------------------------------------------------------
  def param_base(param_id)
    self.class.params[param_id, @level]
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通能力的附加值
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    equips.compact.inject(super) {|r, item| r += item.params[param_id] }
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通攻擊的動畫 ID
  #--------------------------------------------------------------------------
  def atk_animation_id1
    if dual_wield?
      return weapons[0].animation_id if weapons[0]
      return weapons[1] ? 0 : 1
    else
      return weapons[0] ? weapons[0].animation_id : 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通攻擊的動畫 ID （雙持武器：武器２）
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if dual_wield?
      return weapons[1] ? weapons[1].animation_id : 0
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 經驗值變化
  #     show : 等級上升的顯示標志
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    display_level_up(skills - last_skills) if show && @level > last_level
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 獲取經驗值
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 等級上升
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #--------------------------------------------------------------------------
  # ● 等級下降
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # ● 顯示等級上升的信息
  #     new_skills : 學會的新技能的數組
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    $game_message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    new_skills.each do |skill|
      $game_message.add(sprintf(Vocab::ObtainSkill, skill.name))
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲得經驗值（判斷經驗獲取加成）
  #--------------------------------------------------------------------------
  def gain_exp(exp)
    change_exp(self.exp + (exp * final_exp_rate).to_i, true)
  end
  #--------------------------------------------------------------------------
  # ● 計算最終的經驗獲取加成
  #--------------------------------------------------------------------------
  def final_exp_rate
    exr * (battle_member? ? 1 : reserve_members_exp_rate)
  end
  #--------------------------------------------------------------------------
  # ● 獲取不出戰成員的經驗獲取加成
  #--------------------------------------------------------------------------
  def reserve_members_exp_rate
    $data_system.opt_extra_exp ? 1 : 0
  end
  #--------------------------------------------------------------------------
  # ● 等級變化
  #     show : 等級上升顯示的標志
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, max_level].min, 1].max
    change_exp(exp_for_level(level), show)
  end
  #--------------------------------------------------------------------------
  # ● 領悟技能
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● 遺忘技能
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定技能是否已經學會
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    skill.is_a?(RPG::Skill) && @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● 獲取說明
  #--------------------------------------------------------------------------
  def description
    actor.description
  end
  #--------------------------------------------------------------------------
  # ● 職業變化
  #     keep_exp : 是否保留經驗值
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = false)
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更換圖像
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # ● 是否使用精靈
  #--------------------------------------------------------------------------
  def use_sprite?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 執行傷害效果
  #--------------------------------------------------------------------------
  def perform_damage_effect
    $game_troop.screen.start_shake(5, 5, 10)
    @sprite_effect_type = :blink
    Sound.play_actor_damage
  end
  #--------------------------------------------------------------------------
  # ● 執行人物倒下的效果
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      @sprite_effect_type = :collapse
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成自動戰鬥用的行動候選列表
  #--------------------------------------------------------------------------
  def make_action_list
    list = []
    list.push(Game_Action.new(self).set_attack.evaluate)
    usable_skills.each do |skill|
      list.push(Game_Action.new(self).set_skill(skill.id).evaluate)
    end
    list
  end
  #--------------------------------------------------------------------------
  # ● 生成自動戰鬥時的戰鬥行動
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions[i] = make_action_list.max {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成混亂時的戰鬥行動
  #--------------------------------------------------------------------------
  def make_confusion_actions
    @actions.size.times do |i|
      @actions[i].set_confusion
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成戰鬥行動
  #--------------------------------------------------------------------------
  def make_actions
    super
    if auto_battle?
      make_auto_battle_actions
    elsif confusion?
      make_confusion_actions
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色移動一步時的處理
  #--------------------------------------------------------------------------
  def on_player_walk
    @result.clear
    check_floor_effect
    if $game_player.normal_walk?
      turn_end_on_map
      states.each {|state| update_state_steps(state) }
      show_added_states
      show_removed_states
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新狀態的步數計數
  #--------------------------------------------------------------------------
  def update_state_steps(state)
    if state.remove_by_walking
      @state_steps[state.id] -= 1 if @state_steps[state.id] > 0
      remove_state(state.id) if @state_steps[state.id] == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示被附加的狀態
  #--------------------------------------------------------------------------
  def show_added_states
    @result.added_state_objects.each do |state|
      $game_message.add(name + state.message1) unless state.message1.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示被解除的狀態
  #--------------------------------------------------------------------------
  def show_removed_states
    @result.removed_state_objects.each do |state|
      $game_message.add(name + state.message4) unless state.message4.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 地圖上的多少步等于一回合？
  #--------------------------------------------------------------------------
  def steps_for_turn
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 地圖畫面上回合結束的處理
  #--------------------------------------------------------------------------
  def turn_end_on_map
    if $game_party.steps % steps_for_turn == 0
      on_turn_end
      perform_map_damage_effect if @result.hp_damage > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 地形效果判定
  #--------------------------------------------------------------------------
  def check_floor_effect
    execute_floor_damage if $game_player.on_damage_floor?
  end
  #--------------------------------------------------------------------------
  # ● 地形傷害的處理
  #--------------------------------------------------------------------------
  def execute_floor_damage
    damage = (basic_floor_damage * fdr).to_i
    self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取地形傷害的基礎值
  #--------------------------------------------------------------------------
  def basic_floor_damage
    return 10
  end
  #--------------------------------------------------------------------------
  # ● 獲取地形傷害的最大值
  #--------------------------------------------------------------------------
  def max_floor_damage
    $data_system.opt_floor_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 執行地圖上的傷害效果
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
    $game_map.screen.start_flash_for_damage
  end
  #--------------------------------------------------------------------------
  # ● 清除戰鬥行動
  #--------------------------------------------------------------------------
  def clear_actions
    super
    @action_input_index = 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取輸入中的戰鬥行動
  #--------------------------------------------------------------------------
  def input
    @actions[@action_input_index]
  end
  #--------------------------------------------------------------------------
  # ● 進行下一個指令輸入
  #--------------------------------------------------------------------------
  def next_command
    return false if @action_input_index >= @actions.size - 1
    @action_input_index += 1
    return true
  end
  #--------------------------------------------------------------------------
  # ● 返回下一個指令輸入
  #--------------------------------------------------------------------------
  def prior_command
    return false if @action_input_index <= 0
    @action_input_index -= 1
    return true
  end
end
