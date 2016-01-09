#encoding:utf-8
#==============================================================================
# ■ CardBattle::Game_BattleActor
#------------------------------------------------------------------------------
# 　戰鬥人物的類別
#==============================================================================

module CardBattle
class Game_BattleActor
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include ActorInfo
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader :id
  attr_reader :actor_id
  attr_reader :card_hash
  attr_reader :store_card_hash
  attr_reader :real_card_hash
  attr_reader :type
  attr_accessor :general_battle_mode # 一開始選的戰鬥模式
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(actor_id = 0)
    setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 設置角色
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @id = actor_id
    @actor_id = actor_id
    @real_card_hash = CardInfo.init_card_hash_by_actor(@actor_id) # 角色牌組，含天生與購買
    @temp_card_hash = {} # 暫時的卡牌組
    @temp_card_hash.default = 0
    @store_card_hash = {} # 沒出場的卡牌們
    @store_card_hash.default = 0
    @general_battle_mode = nil
    @original_level_up_params = [0]*3 # 沒有combo加成前的數值
    refresh_card_hash
    case @actor_id
    when 2,3
      @type = :attack
    when 1,5
      @type = :speed
    when 4,6
      @type = :magic
    end
    puts "角色模式：#{@type}"
    setup_param
  end
  #--------------------------------------------------------------------------
  # ● 取得成長表格
  #--------------------------------------------------------------------------
  def table
    GROWTH_TABLE[@actor_id]
  end
  #--------------------------------------------------------------------------
  # ● 設置能力數值
  #--------------------------------------------------------------------------
  def setup_param
    @params = [0] * 3
    # 生命
    @params[0] = 100 + self.table[0] * 10
    # 攻擊防禦
    for i in 1..2
      @params[i] = self.table[i]
    end
    @current_hp = mhp
  end
  #--------------------------------------------------------------------------
  # ● 取得各項能力
  #--------------------------------------------------------------------------
  def mhp; @params[0] ; end
  def atk; @params[1] ; end
  def def; @params[2] ; end
  def hp; @current_hp ; end
  #--------------------------------------------------------------------------
  # ● 取得能力(利用index)
  #--------------------------------------------------------------------------
  def params(i)
    @params[i]
  end
  #--------------------------------------------------------------------------
  # ● 產生資料複製
  #--------------------------------------------------------------------------
  def data_dump
    puts "紀錄資訊：#{@params.inspect}"
    Marshal.load(Marshal.dump(self))
  end
  #--------------------------------------------------------------------------
  # ● 設定戰鬥後生命保留
  #--------------------------------------------------------------------------
  def set_post_battle_hp(new_hp,keep = false)
    if keep
      @current_hp = new_hp + (self.mhp*0.5).round
      @current_hp = self.mhp if @current_hp > self.mhp
    else
      @current_hp = self.mhp
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥後處理
  #--------------------------------------------------------------------------
  def post_battle
    @temp_card_hash.clear
    refresh_card_hash
  end
  #--------------------------------------------------------------------------
  # ● 處理升級
  #--------------------------------------------------------------------------
  def process_level_up(rates)
    @original_level_up_params = [0] * 3
    # 生命
    # 生命原本的成長
    @original_level_up_params[0] = @params[0] + ((Math.log10(self.table[0] * 10)/Math.log10(1.5)) ).ceil
    
    add = ((Math.log10(self.table[0] * 10)/Math.log10(1.5)) * rates[0]).ceil
    puts "生命增加：#{add}"
    @params[0] += add
    @current_hp += add
    @current_hp = self.mhp if @current_hp > self.mhp
    # 攻擊防禦
    for i in 1..2
      @original_level_up_params[i] = @params[i] + (self.table[i] ).ceil
      @params[i]+= (self.table[i] * rates[i]).ceil
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲得卡片
  #--------------------------------------------------------------------------
  def gain_card(id,num,source = :forever)
    case source
    when :forever
      target_card_hash = @real_card_hash
    when :temp
      target_card_hash = @temp_card_hash
    when :store
      target_card_hash = @store_card_hash
    end
    if !target_card_hash[id]
      target_card_hash[id] = 0
    end
    puts "獲得卡片ID：#{id} 數量：#{num}"
    target_card_hash[id] += num
    refresh_card_hash
  end
  #--------------------------------------------------------------------------
  # ● 處理模式卡片獎勵
  #--------------------------------------------------------------------------
  def gain_mode_card(mode_index)
    puts "處理模式卡片獎勵"
    case mode_index
    when 0 # 攻擊
      gain_card(CardInfo::ATK_10,1,:temp)
      gain_card(CardInfo::ATK_15,2,:temp)
      # 絕招卡
      skill_ids = CardInfo.type_to_skill_id(self.type)
      if skill_ids.size == 1
        gain_card(skill_ids[0],2,:temp)
      else
        skill_ids.each do |id|
          gain_card(id,1,:temp)
        end
      end
    when 1 # 防禦
      gain_card(CardInfo::DEF_30,2,:temp)
      gain_card(CardInfo::DEF_15,1,:temp)
      # 兩張特殊卡
      2.times do 
        id = [CardInfo::S_IN,CardInfo::S_RE,CardInfo::S_EX].sample
        gain_card(id,1,:temp)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新最後牌組
  #--------------------------------------------------------------------------
  def refresh_card_hash
    @card_hash = @real_card_hash
        .merge(@temp_card_hash) { |key, oldval, newval| oldval + newval }
  end
  #--------------------------------------------------------------------------
  # ● 卡片數量
  #--------------------------------------------------------------------------
  def card_number
    @card_hash.values.inject(0) do |cnt,val|
      cnt += val
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查是否可使用某種卡片
  #--------------------------------------------------------------------------
  def card_usable?(id)
    case @type
    when :attack # 攻擊型，對於速度與魔法絕招不可使用
      return false if [CardBattle::CardInfo::U_SP,CardBattle::CardInfo::U_MA,CardBattle::CardInfo::U_MR].include?(id)
    when :speed
      return false if [CardBattle::CardInfo::U_AT,CardBattle::CardInfo::U_MA,CardBattle::CardInfo::U_MR].include?(id)
    when :magic
      return false if [CardBattle::CardInfo::U_SP,CardBattle::CardInfo::U_AT].include?(id)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 取得能力
  #--------------------------------------------------------------------------
  def param(id)
    @params[id]
  end
  #--------------------------------------------------------------------------
  # ● 取得原本的升級能力
  #--------------------------------------------------------------------------
  def original_level_up_param(id)
    @original_level_up_params[id]
  end
      
end
end