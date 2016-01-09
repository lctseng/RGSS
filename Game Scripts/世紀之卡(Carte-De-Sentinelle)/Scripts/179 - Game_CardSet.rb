#encoding:utf-8
#==============================================================================
# ■ CardBattle::Game_CardSet
#------------------------------------------------------------------------------
# 　戰鬥卡片牌組，為敵人及玩家卡組的超級類
#     定義卡組的基本行為
#==============================================================================

module CardBattle
class Game_CardSet
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader :battler_id
  attr_reader :battle_mode # 戰鬥模式：攻擊(attack)、防禦(defend)、技能(skill)
  attr_reader :max_hp # 最大生命值
  attr_reader :hp # 生命值
  attr_reader :recent_add_cards #最近補充的卡片 (記憶用)
  attr_reader :reserve_card # 保留卡
  attr_reader :selected_cards_flags
  attr_reader :reserved_cards_flags
  attr_reader :skill_enable
  attr_reader :skill_effect
  attr_reader :have_replenish
  attr_accessor :call_for_success
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    clear_all_data
  end
  #--------------------------------------------------------------------------
  # ● 清除所有資料
  #--------------------------------------------------------------------------
  def clear_all_data
    @battler_id = 0
    @card_hash = {} # 卡片雜湊，格式：[卡片ID=>數量]
    @battler_type = nil
    clear_reserve # 清除保留卡
    clear_card_object # 儲存卡片實體的串列，戰鬥開始時清空
    clear_card_table
    clear_skill_data
    @max_hp = 0
    @hp = 0
    @battle_mode = :none
    @call_for_success = nil
  end
  #--------------------------------------------------------------------------
  # ● 清除技能變數
  #--------------------------------------------------------------------------
  def clear_skill_data
    puts "#{self.class}清除技能資訊中..."
    @skill_enable = false # 是否啟動技能
    @skill_effect = nil # 技能效果
  end
  #--------------------------------------------------------------------------
  # ● 設置戰鬥者ID
  #--------------------------------------------------------------------------
  def set_battler_id(val)
    @battler_id = val
  end
  #--------------------------------------------------------------------------
  # ● 取得戰鬥者
  #--------------------------------------------------------------------------
  def battler
    nil
  end
  #--------------------------------------------------------------------------
  # ● 取得戰鬥者屬性
  #--------------------------------------------------------------------------
  def battler_type
    @battler_type
  end
  #--------------------------------------------------------------------------
  # ● 取得Hp比率
  #--------------------------------------------------------------------------
  def hp_rate
    return 0.0 if @max_hp <= 0
    return @hp.to_f / @max_hp
  end
  #--------------------------------------------------------------------------
  # ● 設置戰鬥者
  #--------------------------------------------------------------------------
  def setup_battler(battler_id)
    set_battler_id(battler_id)
  end
  #--------------------------------------------------------------------------
  # ● 單次發牌數
  #--------------------------------------------------------------------------
  def number_of_card_deliver
    6 - @reserve_card.size
  end
  #--------------------------------------------------------------------------
  # ● 單回合保留數
  #--------------------------------------------------------------------------
  def max_reserve_number
    self.battler_type == :magic ? 3 : 2
  end
  #--------------------------------------------------------------------------
  # ● 是否死亡
  #--------------------------------------------------------------------------
  def dead?
    @max_hp > 0 && @hp <= 0
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥設置
  #--------------------------------------------------------------------------
  def battle_setup(battler_id)
    clear_skill_data
    setup_battler(battler_id)
    set_card_object
    clear_action_counter
    @card_table = []
    @atk_plus = 0
    @def_plus = 0
  end
  #--------------------------------------------------------------------------
  # ● 設置預設卡組
  #--------------------------------------------------------------------------
  def setup_default_card_set
    for id in 1..10
      @card_hash[id] = 4
    end
    for id in 14..17
      @card_hash[id] = 5
    end
  end
  #--------------------------------------------------------------------------
  # ● 清空卡片實體
  #--------------------------------------------------------------------------
  def clear_card_object
    @card_list = []
  end
  #--------------------------------------------------------------------------
  # ● 清空桌面卡片(包含已選擇列表)
  #--------------------------------------------------------------------------
  def clear_card_table
    @card_table = []
    @selected_cards_flags = [false]*6
    @reserved_cards_flags = [false]*6
    @selected_cards = [] # 已選擇的卡，固定
    @point_sum = 0 # 卡片點數總和
    @recent_add_cards = [] # 最近補充的卡片 (記憶用)
  end
  #--------------------------------------------------------------------------
  # ● 清空保留卡
  #--------------------------------------------------------------------------
  def clear_reserve
    @reserve_card = []
    @reserved_cards_flags = [false]*6
  end
  #--------------------------------------------------------------------------
  # ● 設置卡牌組實體，產生隨機的卡牌組物件清單
  #      戰鬥開始前必須要呼叫，產生可用的卡
  #--------------------------------------------------------------------------
  def set_card_object
    clear_card_object
    create_card_object
    set_card_order
  end
  #--------------------------------------------------------------------------
  # ● 卡組物件實體化
  #--------------------------------------------------------------------------
  def create_card_object
    @card_hash.each_pair do |id,num|
      card = CardInfo.card_info(id)
      if card
        num.times do
          @card_list.push(card.clone)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得保留卡牌的index
  #--------------------------------------------------------------------------
  def reserved_index_list
    result = []
    @reserved_cards_flags.each_with_index do |val,index|
      if val
        result.push(index)
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● 設置卡組順序
  #--------------------------------------------------------------------------
  def set_card_order
    @card_list.shuffle!
  end
  #--------------------------------------------------------------------------
  # ● 補滿卡牌
  #--------------------------------------------------------------------------
  def refill_card
    puts "卡組數量剩餘 #{@card_list.size} 張，開始補充卡組"
    set_card_object
  end
  #--------------------------------------------------------------------------
  # ● 將保留卡轉移至桌面卡
  #--------------------------------------------------------------------------
  def add_reserve_card_to_table
    @card_table  = @reserve_card
  end
  #--------------------------------------------------------------------------
  # ● 執行補充卡牌的副作用
  #--------------------------------------------------------------------------
  def perform_refill_effect
    
  end
  #--------------------------------------------------------------------------
  # ● 發牌，將卡片加入到桌面，回傳值：發掉的數量
  #      limit：是否發完就沒了(不會進行補充)
  #--------------------------------------------------------------------------
  def deliver_card(limit = true)
    @have_replenish = false
    puts "當前卡數：#{@card_list.size}"
    if limit
      # 不能永遠滿牌
      if empty? # 空牌才補
        # 補充卡牌的副作用
        perform_refill_effect
        refill_card
        @have_replenish = true
      end
    else
      # 可以永遠滿牌
      if @card_list.size < number_of_card_deliver
        # 補充卡牌的副作用
        perform_refill_effect
        refill_card
        @have_replenish = true
      end
    end
    clear_card_table
    add_reserve_card_to_table
    deliver_num = 0
    number_of_card_deliver.times do
      card = @card_list.shift
      if card
        deliver_num += 1
        @card_table.push(card)
        @recent_add_cards.push(card)
      end
    end
    clear_reserve
    clear_normal_skill_data
    
    print_card_set
    puts "總共發了 #{deliver_num} 張卡"
    print_added_card_table
    print_card_table
    
    
    return deliver_num
  end
  #--------------------------------------------------------------------------
  # ● 卡組是否為空?
  #--------------------------------------------------------------------------
  def empty?
    @card_list.empty?
  end
  #--------------------------------------------------------------------------
  # ● 指定模式
  #--------------------------------------------------------------------------
  def set_battle_mode(mode)
    puts "已指定模式為 #{mode}"
    @battle_mode = mode
    if @battle_mode != :attack
      # 若模式不為攻擊，會清掉所有技能效果
      puts "#{self.class}警告！"
      puts "因模式不是攻擊，強制取消技能效果"
      clear_skill_data
    end
  end
  #--------------------------------------------------------------------------
  # ● 自動選擇模式，根據卡片種類與點數分布
  #--------------------------------------------------------------------------
  def auto_select_mode
    puts "模式自動決定中..."
    atk_card_pts = skill_mode_point_adjust(max_attack_pts)
    def_card_pts = max_defend_pts
    puts "攻擊總點數：#{atk_card_pts}"
    puts "防禦總點數：#{def_card_pts}"
    if def_card_pts > atk_card_pts
      # 採取防禦
      puts "採取防禦"
      unselect_skill_cards
      set_battle_mode(:defend)
    else
      # 採取攻擊
      puts "採取攻擊"
      set_battle_mode(:attack)
    end
  end
  #--------------------------------------------------------------------------
  # ● 取消選擇所有技能卡
  #--------------------------------------------------------------------------
  def unselect_skill_cards
    @card_table.each_with_index do |card,index|
      if card.card_type == :skill
        unselect_card_by_index(index)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查是否有合適的技能卡
  #--------------------------------------------------------------------------
  def check_if_exist_ok_skill_card
    skill_cards = card_object_by_type(:skill)
    skill_cards.any? do |card|
      card.card_skill_type == self.battler_type
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查是否有合適的技能卡，若有，則提高攻擊模式評價
  #--------------------------------------------------------------------------
  def skill_mode_point_adjust(origin)
    if enter_critical_attack?
      puts "已進入暴力模式，攻擊評價變為4倍"
      # 已經進入暴力模式，評價變為4倍
      return origin * 4
    elsif magic_type_card_rate_need?
      puts "已進入高度恢復模式，強制選一張恢復卡放著"
      # 是否進入需要補血的狀態，若是，以當前失去血量當作優先權標準
      return (@max_hp - @hp )*2
    else
      puts "攻擊評價照常計算"
      return origin * ( check_if_exist_ok_skill_card ?  2 : 1 )
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得最大攻擊點數
  #--------------------------------------------------------------------------
  def max_attack_pts
    cards = card_object_by_type(:attack)
    card_pts_sum(cards)
  end
  #--------------------------------------------------------------------------
  # ● 取得最大防禦點數
  #--------------------------------------------------------------------------
  def max_defend_pts
    cards = card_object_by_type(:defend)
    card_pts_sum(cards)
  end
  #--------------------------------------------------------------------------
  # ● 取得指定類別卡片實體
  #--------------------------------------------------------------------------
  def card_object_by_type(type)
    @card_table.select do |card|
      card.card_type == type
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得卡片點數總和
  #--------------------------------------------------------------------------
  def card_pts_sum(card_list)
    card_list.inject(0) do |sum,card|
      sum += card.card_point
    end
  end
  #--------------------------------------------------------------------------
  # ● 根據模式自動選卡
  #--------------------------------------------------------------------------
  def auto_select_card
    puts "依照模式 #{@battle_mode} 自動選卡..."
    case @battle_mode
    when :attack
      puts "選取所有攻擊卡"
      select_skill_card
      select_type_cards(:attack)
    when :defend
      puts "選取所有防禦卡"
      select_type_cards(:defend)
    end
    determine_cards
  end
  #--------------------------------------------------------------------------
  # ● 確定選卡，將Flag轉為真正的選擇卡，並計算點數總和
  #--------------------------------------------------------------------------
  def determine_cards
    clear_normal_skill_data
    @selected_cards_flags.each_with_index do |val,index|
      if val
        card = @card_table[index]
        if card.card_type == @battle_mode # 只對攻擊/防禦卡計算點數
          @point_sum += card.card_point
        else
          if @battle_mode == :attack # 只有攻擊時生效
            # 其他卡片類型時
            case card.card_type
            when :skill # 如果選到了技能卡
              if(card.card_skill_type==battler_type) # 如果技能種類相符
                @skill_enable = true # 技能啟動
                @skill_effect = card.card_effect
              end # end if
            end # end case
          end # end if attack
          
        end
        @selected_cards.push(card)
      end
    end
    print_selected_cards
    puts "點數總和為：#{@point_sum}"
  end
  #--------------------------------------------------------------------------
  # ● 是否進入暴力模式 (攻擊必殺的第二階段)
  #--------------------------------------------------------------------------
  def enter_critical_attack?
    @skill_enable && @skill_effect == :attack_last
  end
  #--------------------------------------------------------------------------
  # ● 是否為魔法型且需要恢復生命且此卡為恢復牌
  #--------------------------------------------------------------------------
  def magic_recovery_skill_need?(card)
    # 如果自己不是魔法型，直接通過測試
    return true if self.battler_type != :magic
    # 如果卡片不是恢復卡，直接通過測試
    return true if card.card_effect != :recovery 
    # 到此，已經是魔法型且確定用到了恢復牌
    # 檢查損血是否超過 10%，是的話則使用恢復牌
    return hp_rate < 0.9
  end
  #--------------------------------------------------------------------------
  # ● 是否為魔法型且持有恢復牌且需要恢復
  #--------------------------------------------------------------------------
  def magic_type_card_rate_need?
    # 如果自己不是魔法型，直接不通過
    return false if self.battler_type != :magic
    # 如果生命不夠低，不通過
    return false if hp_rate > 0.9
    
    # 檢查每張持有的魔法牌，檢查是否有可用恢復牌
    @card_table.each_with_index do |card,index|
      if card.card_type == :skill && card.card_effect == :recovery
        # 強制選牌
        select_card_by_index(index,true) 
        puts "已經強制選牌：#{card.inspect}"
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 是不是已經選了某張之前特別需要的技能卡了
  #--------------------------------------------------------------------------
  def pre_skill_card_selected?
    temp_select_cards.any? do |card|
      card.card_type == :skill
    end
  end
  #--------------------------------------------------------------------------
  # ● 選擇一張符合自己技能類別的技能卡(若有的話)
  # 此外必須滿足不覆蓋掉前次的暴力型持續
  #--------------------------------------------------------------------------
  def select_skill_card
    return if enter_critical_attack?
    return if pre_skill_card_selected?
    @card_table.each_with_index do |card,index|
      if card.card_type == :skill && card.card_skill_type == self.battler_type && magic_recovery_skill_need?(card)
        select_card_by_index(index)
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 選擇所有某模式的卡
  #--------------------------------------------------------------------------
  def select_type_cards(type)
    @card_table.each_with_index do |card,index|
      if card.card_type == type
        select_card_by_index(index)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查某卡的選擇狀態，根據index
  #--------------------------------------------------------------------------
  def card_select_state(index)
    @selected_cards_flags[index]
  end
  #--------------------------------------------------------------------------
  # ● 選卡，根據index，卡片無法選擇時回強制設定為false
  # force ： 強制選上
  #--------------------------------------------------------------------------
  def select_card_by_index(index,force = false)
    card = @card_table[index]
    if card
      if force || card_usable?(card)
        @selected_cards_flags[index] = true
      else
        puts "#{self.class}警告："
        puts "試圖選取無法使用的卡片，索引：#{index}，#{card.inspect}"
        @selected_cards_flags[index] = false
      end
    else
      puts "#{self.class}錯誤！："
      puts "試圖選取不存在的卡片，索引：#{index}"
    end
    
    
  end
  #--------------------------------------------------------------------------
  # ● 取消選卡，根據index
  #--------------------------------------------------------------------------
  def unselect_card_by_index(index)
    @selected_cards_flags[index] = false
  end
  #--------------------------------------------------------------------------
  # ● Toggle選卡狀態，根據index，無修正
  #--------------------------------------------------------------------------
  def toggle_card_select_by_index(index)
    @selected_cards_flags[index] = !@selected_cards_flags[index]
  end
  #--------------------------------------------------------------------------
  # ● 保留牌的價值
  #--------------------------------------------------------------------------
  def card_reserving_value(card)
    if card.card_type == :skill # 如果是技能牌
      if card.card_skill_type == battler_type
        # 種類相符的技能牌
        return 100
      else
        return 0 # 其他技能牌都沒價值
      end
    else
      return card.card_value
    end
  end
  #--------------------------------------------------------------------------
  # ● 自動保留卡組 (根據剩下沒用的牌)
  #--------------------------------------------------------------------------
  def process_reserve_cards
    # 取得剩下牌
    remain_card = []
    @selected_cards_flags.each_with_index do |val,index|
      if !val # 如果該卡還沒被用掉
        card = @card_table[index]
        if card && card.usable? && card_reserving_value(card) > 0 # 如果卡片有效且有保留價值
          remain_card.push([card,index])
        end
      end
    end
    
    # 排序剩下牌
    remain_card.sort! do |a,b|
      card_reserving_value(b[0]) - card_reserving_value(a[0])
    end
    
    puts "剩下沒用到的卡："
    print_card_list(remain_card.collect{|data| data[0]})
    
    # 根據保留數保留卡牌
    reserve_card_data =  (remain_card[0,max_reserve_number].compact) || []
    
    # 把保留卡放入保留陣列，並設定旗標
    @reserve_card = []
    reserve_card_data.each do |data|
      @reserve_card.push(data[0])
      @reserved_cards_flags[data[1]] = true
    end
    
    print_reserve_card
    
    
    
  end
  #--------------------------------------------------------------------------
  # ● 回合結果平手處理
  #--------------------------------------------------------------------------
  def on_even
    puts "#{self.class} 此回合平手"
  end
  #--------------------------------------------------------------------------
  # ● 攻擊成功
  #--------------------------------------------------------------------------
  def on_attack_result(diff)
    puts "#{self.class} 攻擊成功，點數：#{diff}"
  end
  #--------------------------------------------------------------------------
  # ● 遭到攻擊
  #--------------------------------------------------------------------------
  def on_begin_attack(diff)
    puts "#{self.class} 遭到攻擊 #{diff} 點"
    lose_hp(diff)
  end
  #--------------------------------------------------------------------------
  # ● 失去生命值
  #--------------------------------------------------------------------------
  def lose_hp(value)
    lose_value = [value.round,@hp].min
    puts "#{self.class} 的HP有 #{@hp} 點，將損失 #{lose_value} 點"
    @hp -= lose_value
    puts "#{self.class} 剩餘HP：#{@hp} 點"
  end
  #--------------------------------------------------------------------------
  # ● 增加生命值
  #--------------------------------------------------------------------------
  def gain_hp(value)
    gain_value = [value.round,@max_hp - @hp].min
    puts "#{self.class} 的HP有 #{@hp} 點，將恢復 #{gain_value} 點"
    @hp += gain_value
    puts "#{self.class} 剩餘HP：#{@hp} 點"

  end
  #--------------------------------------------------------------------------
  # ● 恢復生命值比率
  #--------------------------------------------------------------------------
  def recover_hp_rate(rate)
    puts "#{self.class}恢復生命：#{(rate*100).round}%"
    gain_hp(rate*@max_hp + 1.0)
  end
  #--------------------------------------------------------------------------
  # ● 失去生命值比率
  #--------------------------------------------------------------------------
  def lose_hp_rate(rate,die = true)
    puts "#{self.class}失去生命：#{(rate*100).round}%"
    val = rate*@max_hp + 1.0
    if !die && val >= @hp
      val = @hp - 1
    end
    lose_hp(val)
  end
  #--------------------------------------------------------------------------
  # ● 攻擊遭到阻擋
  #--------------------------------------------------------------------------
  def on_attack_blocked
    puts "#{self.class} 的攻擊遭到阻擋..."
    if @skill_enable && @skill_effect == :attack_first
      # 如果剛好使用攻擊型技能，且效果為第一輪，則效果中止
      puts "由於使用了攻擊型必殺技仍被阻擋，效果消失！"
      clear_skill_data
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否還有空間可以保留？
  #--------------------------------------------------------------------------
  def reserve_size_enough?
    @reserved_cards_flags.select { |val| val}.size < max_reserve_number
  end
  #--------------------------------------------------------------------------
  # ● 將保留卡旗標轉為真正卡片
  #--------------------------------------------------------------------------
  def parse_reserved_card
    @reserved_cards_flags.each_with_index do |val,index|
      if val
        card = @card_table[index]
        @reserve_card.push(card)
      end
    end

  end
  #--------------------------------------------------------------------------
  # ● 設置桌上卡組
  #--------------------------------------------------------------------------
  def set_card_table(table)
    @card_table = table
  end

  #--------------------------------------------------------------------------
  # ● 取得桌上卡組
  #--------------------------------------------------------------------------
  def current_card_table
    @card_table
  end
  #--------------------------------------------------------------------------
  # ● 桌上卡組交換
  #--------------------------------------------------------------------------
  def card_table_swap(target_set)
    my_table = @card_table
    @card_table = target_set.current_card_table
    target_set.set_card_table(my_table)
    # 交換後的清除
    target_set.clear_on_exchange
    self.clear_on_exchange
    
  end
  #--------------------------------------------------------------------------
  # ● 交換卡組時的清除
  #--------------------------------------------------------------------------
  def clear_on_exchange
    @selected_cards_flags = [false]*6
    @reserved_cards_flags = [false]*6
    @selected_cards = [] # 已選擇的卡，固定
    @point_sum = 0 # 卡片點數總和
    @recent_add_cards = [] # 最近補充的卡片 (記憶用)
    clear_normal_skill_data
    clear_reserve
  end
  #--------------------------------------------------------------------------
  # ● 清除技能一般卡資訊，但如果技能資訊是保留過來的，則不清除
  #--------------------------------------------------------------------------
  def clear_normal_skill_data
    if @skill_enable && @skill_effect == :attack_last
      puts "前次使用力型必殺技，交換後效果仍保留"
    else
      puts "清除上次選卡造成的技能資訊"
      clear_skill_data
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除行動計數器
  #--------------------------------------------------------------------------
  def clear_action_counter
    @attack_success = 0
    @defend_success = 0
    @defend_accu = 0 # 防禦累積
    @attack_combo_ok = false # 是否完成連續攻擊
    @defend_combo_ok = false # 是否完成連續防禦
    clear_defend_point
  end  
  #--------------------------------------------------------------------------
  # ● 清除防禦點數
  #--------------------------------------------------------------------------
  def clear_defend_point
    @defend_points = [0] * MAGIC_ATTACK_MAX_DEFEND_TIME # 最近幾次防禦數值
  end
  #--------------------------------------------------------------------------
  # ● 增加防禦點數
  #--------------------------------------------------------------------------
  def add_defend_point(pts)
    @defend_points.shift
    @defend_points.push(pts)
  end
  #--------------------------------------------------------------------------
  # ● 攻擊成功
  #--------------------------------------------------------------------------
  def attack_success
    stop_defend
    @attack_success += 1 
    if !@attack_combo_ok && @attack_success >= 3 && battler.general_battle_mode == :attack 
      puts "攻擊獎勵開啟"
      @attack_combo_ok = true
      @call_for_success = :attack
    end
    print_action_counter
  end
  #--------------------------------------------------------------------------
  # ● 防禦成功
  #--------------------------------------------------------------------------
  def defend_success(diff)
    stop_attack
    @defend_success += 1 
    if !@defend_combo_ok && @defend_success >= 2 && battler.general_battle_mode == :defend
      puts "防禦獎勵開啟"
      @defend_combo_ok = true
      @call_for_success = :defend
    end
    # 防禦傷害累積：只有非魔法型才有
    if self.battler_type != :magic && @defend_success <= 3
      @defend_accu += diff
    else
      puts "防禦累積傷害已經超過回合上限，數值#{diff}將被捨棄"
    end
    
    print_action_counter
  end
  #--------------------------------------------------------------------------
  # ● 攻擊失敗
  #--------------------------------------------------------------------------
  def attack_failure
    stop_defend
    stop_attack
    print_action_counter
  end 
  #--------------------------------------------------------------------------
  # ● 防禦失敗
  #--------------------------------------------------------------------------
  def defend_failure
    stop_defend
    stop_attack
    print_action_counter
  end  
  #--------------------------------------------------------------------------
  # ● 攻擊平手
  #--------------------------------------------------------------------------
  def attack_even
    stop_defend
  end
  #--------------------------------------------------------------------------
  # ● 防禦平手
  #--------------------------------------------------------------------------
  def defend_even
    stop_attack
  end
  #--------------------------------------------------------------------------
  # ● 中斷攻擊
  #--------------------------------------------------------------------------
  def stop_attack
    @attack_success = 0
  end
  #--------------------------------------------------------------------------
  # ● 中斷防禦
  #--------------------------------------------------------------------------
  def stop_defend
    @defend_success = 0
    @defend_accu = 0
  end
  #--------------------------------------------------------------------------
  # ● 列印行動計數器
  #--------------------------------------------------------------------------
  def print_action_counter
    puts "連續攻擊：#{@attack_success}，連續防禦：#{@defend_success}，防禦累積：#{@defend_accu}"
  end
  #--------------------------------------------------------------------------
  # ● 取得戰鬥點數
  #--------------------------------------------------------------------------
  def point_sum
    @effective_point_sum
  end
  #--------------------------------------------------------------------------
  # ● 產生戰鬥點數
  #--------------------------------------------------------------------------
  def generate_point_sum
    @effective_point_sum = eval_point_sum
    # 連續防禦效果
    if [:attack,:skill].include? self.battle_mode
      puts "攻擊傷害增幅：#{@defend_accu}"
      @effective_point_sum += @defend_accu
    end
  end
  #--------------------------------------------------------------------------
  # ● 計算戰鬥點數
  #--------------------------------------------------------------------------
  def eval_point_sum
    puts "計算戰鬥點數，#{self.class}的角色類別：#{battler_type}"
    # 加上基礎數值
    case self.battle_mode
    when :attack,:skill
      @point_sum += self.battler.atk  + @atk_plus
    when :defend
      @point_sum += self.battler.def  + @def_plus
    end
    # 技能處理
    if @skill_enable
      # 技能啟動
      case self.battler_type
      when :speed
        # 速度型
        puts "速度型啟動，點數3倍計算！原始：#{@point_sum}"
        return @point_sum * 3
      when :attack
        # 攻擊型
        case @skill_effect # 根據持續階段決定倍率
        when :attack_first
          puts "攻擊型第一階段，原始傷害：#{@point_sum}，倍率1.5"
          return ((@point_sum  + 0.5) * 1.5).round
        when :attack_last
          puts "攻擊型第二階段，原始傷害：#{@point_sum}，倍率4.0"
          return ((@point_sum  + 0.5) * 4.0).round
        end
      when :magic
        # 魔法型，累積過去防禦數值
        max_def_add = @point_sum * 5
        puts "防禦紀錄：#{@defend_points}"
        sum = @defend_points.reduce(:+)
        puts "魔法型防禦累積數值：#{sum}，上限值：#{max_def_add}"
        sum = max_def_add if sum > max_def_add
        if @skill_effect == :recovery
          sum = sum / 2
        end
        clear_defend_point
        
        return @point_sum + sum
      else
        return @point_sum # 正常值
      end
    else
      # 正常行動
      return @point_sum
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥傷害計算結束後處理
  #--------------------------------------------------------------------------
  def post_battle_execute
    post_battle_clear_skill
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥傷害計算結束 - 技能處理
  #--------------------------------------------------------------------------
  def post_battle_clear_skill
    # 處理恢復，沒死才能回
    if @skill_enable && @skill_effect == :recovery && !dead?
      recover_hp_rate(0.15)
      @skill_enable = false
      @skill_effect = nil
    elsif @skill_enable && @skill_effect == :attack_first
      # 如果為攻擊必殺，在計算傷害時沒有失敗
      # 則保留技能開啟，並更換技能階段
      @skill_effect = :attack_last # 更換為暴力階段
    else
      @skill_enable = false
      @skill_effect = nil
    end

  end
  #--------------------------------------------------------------------------
  # ● 回合開始
  #--------------------------------------------------------------------------
  def turn_start
    puts "回合開始準備：#{self.class}"
    puts "生命值：#{self.hp} / #{self.max_hp}"
    puts "技能啟動標記：#{@skill_enable}"
    puts "技能效果：#{@skill_effect}"
    # 清除卡片點數總和
    @effective_point_sum = 0
  end
  #--------------------------------------------------------------------------
  # ● 檢視桌上卡牌中，卡片index狀態
  #--------------------------------------------------------------------------
  def show_index_status
    puts "檢視卡牌物件index狀態"
    @card_table.each_with_index do |card,index|
      puts "index：#{index}，卡片：#{card.inspect}"
    end
  end
  #--------------------------------------------------------------------------
  # ● 藉由精靈陣列來同步桌面卡組
  #--------------------------------------------------------------------------
  def sync_card_table_index_with_sprite(sprite_list)
    sprite_list.each_with_index do |sprite,index|
      card_obj = sprite.card_obj
      break if !card_obj
      puts "正在同步...index：#{index}，目標：#{card_obj.inspect}"
      @card_table[index] = card_obj
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 檢查某張卡片是否可用
  #--------------------------------------------------------------------------
  def card_usable?(card)
    puts "檢查卡片：#{card.inspect}"
    return false if !card.usable?
    return false if  card.is_skill?&&!check_skill_card_valid(card)
    return true
    
  end
  #--------------------------------------------------------------------------
  # ● 檢查某張技能卡能不能用
  #--------------------------------------------------------------------------
  def check_skill_card_valid(card) 
    @battle_mode == :attack && card.is_skill_for_type(self.battler_type) && check_skill_card_select_limit
  end
  #--------------------------------------------------------------------------
  # ● 檢查技能卡選擇數量是否滿足
  #--------------------------------------------------------------------------
  def check_skill_card_select_limit
    # 若已選卡之中已經有必殺技，則false
    temp_select_cards.each do |card|
      if card.card_type == :skill
        return false
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 取得暫時已選的卡列表
  #--------------------------------------------------------------------------
  def temp_select_cards
    list = []
    @card_table.each_with_index do |card,index|
      if @selected_cards_flags[index]
        list.push(card)
      end
    end
    list
  end
  #--------------------------------------------------------------------------
  # ● 檢查無視防禦是否成立
  #--------------------------------------------------------------------------
  def ignore_defend_ok?
    @skill_enable && @skill_effect == :real_damage
  end
  #--------------------------------------------------------------------------
  # ● 取得技能資料
  #--------------------------------------------------------------------------
  def skill_data
    {:enable => @skill_enable , :effect => @skill_effect}
  end
  #--------------------------------------------------------------------------
  # ● 是否是玩家
  #--------------------------------------------------------------------------
  def player?
    false
  end
  #--------------------------------------------------------------------------
  # ● 是否是敵人
  #--------------------------------------------------------------------------
  def enemy?
    false
  end
  #--------------------------------------------------------------------------
  # ● 能力提升
  #--------------------------------------------------------------------------
  def power_up_by_rate(rate)
    @atk_plus += (self.battler.atk * 0.5).ceil
    @def_plus += (self.battler.def * 0.5).ceil
  end
  #--------------------------------------------------------------------------
  # ● 數值精靈的位置(抽象方法)
  #--------------------------------------------------------------------------
  def number_sprite_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 框架精靈檔名(抽象方法)
  #--------------------------------------------------------------------------
  def frame_filename
    
  end
  #--------------------------------------------------------------------------
  # ● 框架精靈位置(抽象方法)
  #--------------------------------------------------------------------------
  def frame_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 模式精靈檔名列表(抽象方法)
  #--------------------------------------------------------------------------
  def mode_filename_list
    []
  end
  #--------------------------------------------------------------------------
  # ● 模式精靈位置(抽象方法)
  #--------------------------------------------------------------------------
  def mode_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 總和精靈的位置(抽象方法)
  #--------------------------------------------------------------------------
  def sum_sprite_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 肖像精靈的位置(抽象方法)
  #--------------------------------------------------------------------------
  def portrait_sprite_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 計數器精靈位置(抽象方法)
  #--------------------------------------------------------------------------
  def counter_sprite_pos
    
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥後處理
  #--------------------------------------------------------------------------
  def post_battle
    
  end
  #--------------------------------------------------------------------------
  # ● 取得戰鬥計數器
  #--------------------------------------------------------------------------
  def get_battler_counter
    0
  end
  #--------------------------------------------------------------------------
  # ● 是否顯示攻擊型第二階段
  #--------------------------------------------------------------------------
  def show_attack_last?
    self.battler_type == :attack && @skill_enable && @skill_effect == :attack_last
  end  
  #--------------------------------------------------------------------------
  # ● 顯示防禦球？
  #--------------------------------------------------------------------------
  def show_defend_ball?
    false
  end
  

  #--------------------------------------------------------------------------
  # ● 列印新補充桌面上卡
  #--------------------------------------------------------------------------
  def print_added_card_table
    puts "新補充的桌面上卡牌內容："
    @recent_add_cards.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "新補充的桌面上卡片列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印桌面上卡
  #--------------------------------------------------------------------------
  def print_card_table
    puts "桌面上卡牌內容："
    @card_table.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "桌面上卡片列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印保留的卡
  #--------------------------------------------------------------------------
  def print_reserve_card
    puts "保留的卡牌內容："
    @reserve_card.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "保留的卡片列表結束"
  end

  #--------------------------------------------------------------------------
  # ● 列印牌組
  #--------------------------------------------------------------------------
  def print_card_set
    return
    puts "卡組中剩餘 #{@card_list.size} 張卡，卡組列表"
    @card_list.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "卡組列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印暫時出擊的卡
  #--------------------------------------------------------------------------
  def print_temp_selected_cards
    puts "顯示：暫時出擊卡片列表"
    @card_table.each_with_index do |card,index|
      if @selected_cards_flags[index]
        puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
      end
    end
    puts "暫時出擊的卡片列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印暫時選擇的卡
  #--------------------------------------------------------------------------
  def print_temp_reserved_cards
    puts "顯示：暫時保留卡片列表"
    puts "最大保留數為：#{max_reserve_number}，當前保留數：#{@reserved_cards_flags.select { |val| val}.size}"
    @card_table.each_with_index do |card,index|
      if @reserved_cards_flags[index]
        puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
      end
    end
    puts "暫時保留的卡片列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印選擇的卡
  #--------------------------------------------------------------------------
  def print_selected_cards
    puts "已選擇 #{@selected_cards.size} 張卡"
    @selected_cards.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "已選的卡片列表結束"
  end
  #--------------------------------------------------------------------------
  # ● 列印某卡片列表
  #--------------------------------------------------------------------------
  def print_card_list(list)
    puts "列表"
    list.each_with_index do |card,index|
      puts "第 #{index+1} 張卡片，ID：#{card.card_id}，類別：#{card.card_type}，點數：#{card.card_point}"
    end
    puts "列表結束"
  end


end
end