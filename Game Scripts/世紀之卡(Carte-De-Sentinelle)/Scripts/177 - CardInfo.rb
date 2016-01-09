#==============================================================================
# ■ CardBattle::CardInfo
#------------------------------------------------------------------------------
# 　戰鬥卡資料設定
#==============================================================================

module CardBattle
module CardInfo
  
  #--------------------------------------------------------------------------
  # ● 新增一張卡片至資料庫
  #--------------------------------------------------------------------------
  def self.add_card(new_ins)
    new_ins.card_id = @id_count
    @data[@id_count] = new_ins
    @id_count += 1
  end
  #--------------------------------------------------------------------------
  # ● 利用ID取得卡片 
  #--------------------------------------------------------------------------
  def self.card_info(id)
    @data[id]
  end
  #--------------------------------------------------------------------------
  # ● 由種類取得必殺卡ID
  #--------------------------------------------------------------------------
  def self.type_to_skill_id(type)
    puts "玩家類型:#{type}"
    id  = []
    case type
    when :attack
      id.push(U_AT)
    when :speed
      id.push(U_SP)
    when :magic
      id.push(U_MA)
      id.push(U_MR)
    end
    return id
  end
  #--------------------------------------------------------------------------
  # ● 卡片ID對應名稱
  #--------------------------------------------------------------------------
  ATK_3 = 1
  ATK_5 = 2
  ATK_10 = 3
  ATK_15 = 4
  ATK_30 = 5
  
  DEF_3 = 6
  DEF_5 = 7
  DEF_10 = 8
  DEF_15 = 9
  DEF_30 = 10
  
  S_IN = 11
  S_RE = 12
  S_EX = 13
  
  U_SP = 14
  U_AT = 15
  U_MA = 16
  U_MR = 17

  #--------------------------------------------------------------------------
  # ● 設定各角色對應到的初始卡組
  #--------------------------------------------------------------------------
  def self.init_card_hash_by_actor(actor_id)
    card_hash = {}
    card_hash.default = 0
      
#~     # TODO：測試補充
#~     card_hash[ATK_3] = 1
#~     card_hash[ATK_5] = 3
#~     card_hash[ATK_10] = 3
#~     
#~     
    
    case actor_id
    when 1 # 斐恩
      # 攻擊: +3 (1)		+5 (2)		+10(2)		+15 (4)	+30 (2)
      card_hash[ATK_3] = 5
      card_hash[ATK_5] = 5
      card_hash[ATK_10] = 5
      card_hash[ATK_15] = 5
      card_hash[ATK_30] = 5
      # 防禦: +3 (3)		+5 (3)		+10 (1)	+15 (5)	+30 (3)
      card_hash[DEF_3] = 4
      card_hash[DEF_5] = 4
      card_hash[DEF_10] = 4
      card_hash[DEF_15] = 4
      card_hash[DEF_30] = 4
      # 特殊: 重新抽牌 (1)	牌組交換 (2)	防礙 (2)
      card_hash[S_RE] = 2
      card_hash[S_EX] = 2
      card_hash[S_IN] = 3
      # 必殺: 8
      card_hash[U_SP] = 8
    when 2 # 亞莎
      # 攻擊: +3 (3)		+5 (2)		+10 (2)	+15 (3)	+30 (3)
      card_hash[ATK_3] = 6
      card_hash[ATK_5] = 6
      card_hash[ATK_10] = 6
      card_hash[ATK_15] = 5
      card_hash[ATK_30] = 5
      # 防禦: +3 (3)		+5 (3)		+10 (4)	+15 (2)	+30 (4)
      card_hash[DEF_3] = 4
      card_hash[DEF_5] = 4
      card_hash[DEF_10] = 4
      card_hash[DEF_15] = 4
      card_hash[DEF_30] = 3
      # 特殊: 重新抽牌 (1)	牌組交換 (2)	防礙 (2)
      card_hash[S_RE] = 2
      card_hash[S_EX] = 2
      card_hash[S_IN] = 2
      # 必殺: 6
      card_hash[U_AT] = 7
    when 3 # 赤琥
      # 攻擊: +3 (3)		+5 (2)		+10 (4)	+15 (5)	+30 (2)
      card_hash[ATK_3] = 7
      card_hash[ATK_5] = 5
      card_hash[ATK_10] = 5
      card_hash[ATK_15] = 5
      card_hash[ATK_30] = 5
      # 防禦: +3 (2)		+5 (4)		+10 (2)	+15 (2)	+30 (3)
      card_hash[DEF_3] = 4
      card_hash[DEF_5] = 4
      card_hash[DEF_10] = 4
      card_hash[DEF_15] = 4
      card_hash[DEF_30] = 4
      # 特殊: 重新抽牌 (2)	牌組交換 (1)	防礙 (2)
      card_hash[S_RE] = 3
      card_hash[S_EX] = 2
      card_hash[S_IN] = 2
      # 必殺: 6
      card_hash[U_AT] = 6
    when 4 # 蒼玉
      # 攻擊: +3 (2)		+5 (3)		+10 (3)	+15 (6)	+30 (2)
      card_hash[ATK_3] = 5
      card_hash[ATK_5] = 5
      card_hash[ATK_10] = 5
      card_hash[ATK_15] = 5
      card_hash[ATK_30] = 4
      # 防禦: +3 (1)		+5 (3)		+10 (4)	+15 (2)	+30 (2)
      card_hash[DEF_3] = 5
      card_hash[DEF_5] = 5
      card_hash[DEF_10] = 4
      card_hash[DEF_15] = 4
      card_hash[DEF_30] = 4
      # 特殊: 重新抽牌 (1)	牌組交換 (2)	防礙 (2)
      card_hash[S_RE] = 1
      card_hash[S_EX] = 2
      card_hash[S_IN] = 2
      # 必殺: 無視對方防禦 (5)	補15%我方HP (5)
      card_hash[U_MA] = 5
      card_hash[U_MR] = 4
    when 5 # 洛倫
      # 攻擊: +3 (5)		+5 (2)		+10 (3)	+15 (2)	+30 (3)
      card_hash[ATK_3] = 5
      card_hash[ATK_5] = 5
      card_hash[ATK_10] = 5
      card_hash[ATK_15] = 4
      card_hash[ATK_30] = 4
      # 防禦: +3 (2)		+5 (2)		+10 (1)	+15 (4)	+30 (2)
      card_hash[DEF_3] = 5
      card_hash[DEF_5] = 4
      card_hash[DEF_10] = 4
      card_hash[DEF_15] = 4
      card_hash[DEF_30] = 4
      # 特殊: 重新抽牌 (3)	牌組交換 (2)	防礙 (1)
      card_hash[S_RE] = 2
      card_hash[S_EX] = 2
      card_hash[S_IN] = 2
      # 必殺: 8
      card_hash[U_SP] = 10
    when 6 # 瑪雅
      # 攻擊: +3 (3)		+5 (4)		+10 (2)	+15 (3)	+30 (4)
      card_hash[ATK_3] = 5
      card_hash[ATK_5] = 4
      card_hash[ATK_10] = 4
      card_hash[ATK_15] = 4
      card_hash[ATK_30] = 4
      # 防禦: +3 (1)		+5 (3)		+10 (2)	+15 (3)	+30 (1)
      card_hash[DEF_3] = 5
      card_hash[DEF_5] = 5
      card_hash[DEF_10] = 5
      card_hash[DEF_15] = 5
      card_hash[DEF_30] = 5
      # 特殊: 重新抽牌 (2)	牌組交換 (2)	防礙 (3)
      card_hash[S_RE] = 1
      card_hash[S_EX] = 1
      card_hash[S_IN] = 3
      # 必殺: 無視對方防禦 (3)	補15%我方HP (6)
      card_hash[U_MA] = 3
      card_hash[U_MR] = 6
    end
    ## 回傳
    return card_hash
  end
  #--------------------------------------------------------------------------
  # ● 設定各敵人對應到的初始卡組
  #--------------------------------------------------------------------------
  def self.init_enemy_card_hash(enemy_id)
    card_hash = {}
    card_hash.default = 0
    case enemy_id
    when 4,7,11,16,18,23,24,14
      # 攻擊型共通
      # (攻擊 +3: 23張，+5: 24張，+10: 12張，+15: 8張，+30: 28張)
      # (防禦 +3: 16張，+5: 17張，+10: 10張，+15: 5張，+30: 22張)
      # 攻擊
      card_hash[ATK_3] = 23
      card_hash[ATK_5] = 24
      card_hash[ATK_10] = 12
      card_hash[ATK_15] = 8
      card_hash[ATK_30] = 28
      # 防禦
      card_hash[DEF_3] = 16
      card_hash[DEF_5] = 17
      card_hash[DEF_10] = 10
      card_hash[DEF_15] = 5
      card_hash[DEF_30] = 22
      # 特殊
      card_hash[S_RE] = 3
      card_hash[S_EX] = 3
      card_hash[S_IN] = 4
      # 必殺
      card_hash[U_AT] = 5
    when 9,21,25,13
      # 速度型共通
      # (攻擊 +3: 21張，+5: 22張，+10: 16張 ，+15: 18張，+30: 19)
      # (防禦 +3: 14張，+5: 13張，+10: 11張，+15: 5張，+30: 19)
      # 攻擊
      card_hash[ATK_3] = 21
      card_hash[ATK_5] = 22
      card_hash[ATK_10] = 16
      card_hash[ATK_15] = 18
      card_hash[ATK_30] = 19
      # 防禦
      card_hash[DEF_3] = 14
      card_hash[DEF_5] = 13
      card_hash[DEF_10] = 11
      card_hash[DEF_15] = 5
      card_hash[DEF_30] = 19
      # 特殊
      card_hash[S_RE] = 4
      card_hash[S_EX] = 4
      card_hash[S_IN] = 4
      # 必殺
      card_hash[U_SP] = 10
    when 10,12,22
      # 魔法型共通
      # (攻擊 +3: 13，+5: 12，+10: 7，+15: 19，+30: 19)
      # (防禦 +3: 13，+5: 12，+10: 7，+15: 19，+30: 19)
      # 攻擊
      card_hash[ATK_3] = 13
      card_hash[ATK_5] = 12
      card_hash[ATK_10] = 7
      card_hash[ATK_15] = 19
      card_hash[ATK_30] = 19
      # 防禦
      card_hash[DEF_3] = 13
      card_hash[DEF_5] = 12
      card_hash[DEF_10] = 7
      card_hash[DEF_15] = 19
      card_hash[DEF_30] = 19
      # 特殊
      card_hash[S_RE] = 6
      card_hash[S_EX] = 6
      card_hash[S_IN] = 6
      # 必殺
      card_hash[U_MA] = 11
      card_hash[U_MR] = 11
    when 26,27
      # 迪亞特
      # (攻擊 +3:20，+5: 19，+10: 13，+15: 17，+30: 21)
      # (防禦 +3: 15，+5: 16，+10: 11，+15: 16，+30: 15)
      # 攻擊
      card_hash[ATK_3] = 20
      card_hash[ATK_5] = 19
      card_hash[ATK_10] = 13
      card_hash[ATK_15] = 17
      card_hash[ATK_30] = 21
      # 防禦
      card_hash[DEF_3] = 15
      card_hash[DEF_5] = 16
      card_hash[DEF_10] = 11
      card_hash[DEF_15] = 16
      card_hash[DEF_30] = 15
      # 特殊
      card_hash[S_RE] = 4
      card_hash[S_EX] = 3
      card_hash[S_IN] = 3
      # 必殺
      card_hash[U_AT] = 7
    when 1,6,8,17,19,28
      # 暗夜刺客&佛格&尼德霍格&殺手會長(速度)
      # (攻擊 +3: 19，+5: 20，+10: 17，+15: 18，+30: 20)
      # (防禦 +3: 12，+5: 13，+10: 12，+15: 15，+30: 10)
      # 攻擊
      card_hash[ATK_3] = 15
      card_hash[ATK_5] = 16
      card_hash[ATK_10] = 10
      card_hash[ATK_15] = 16
      card_hash[ATK_30] = 26
      # 防禦
      card_hash[DEF_3] = 11
      card_hash[DEF_5] = 12
      card_hash[DEF_10] = 7
      card_hash[DEF_15] = 8
      card_hash[DEF_30] = 22
      # 特殊
      card_hash[S_RE] = 4
      card_hash[S_EX] = 4
      card_hash[S_IN] = 4
      # 必殺
      card_hash[U_SP] = 112
    when 29,30,15,20,2,3,5
      # 魔王&黑暗
      # (攻擊 +3: 15，+5: 16，+10: 10，+15: 16，+30: 26
      # (防禦+3: 11，+5: 12 ，+10: 7，+15: 8， +30: 22)
      # 攻擊
      card_hash[ATK_3] = 15
      card_hash[ATK_5] = 16
      card_hash[ATK_10] = 10
      card_hash[ATK_15] = 16
      card_hash[ATK_30] = 26
      # 防禦
      card_hash[DEF_3] = 11
      card_hash[DEF_5] = 12
      card_hash[DEF_10] = 7
      card_hash[DEF_15] = 8
      card_hash[DEF_30] = 22
      # 特殊
      card_hash[S_RE] = 4
      card_hash[S_EX] = 4
      card_hash[S_IN] = 3
      # 必殺
      card_hash[U_MA] = 18
      card_hash[U_MR] = 6
    end
    return card_hash
  end
  #--------------------------------------------------------------------------
  # ● 卡片ID轉換成檔案名稱
  #--------------------------------------------------------------------------
  def self.card_id_to_name(id)
    case id
    when ATK_3
      "card_atk_3"
    when ATK_5
      "card_atk_5"
    when ATK_10
      "card_atk_10"
    when ATK_15
      "card_atk_15"
    when ATK_30
      "card_atk_30"
    when DEF_3
      "card_def_3"
    when DEF_5
      "card_def_5"
    when DEF_10
      "card_def_10"
    when DEF_15
      "card_def_15"
    when DEF_30
      "card_def_30"
    when S_IN
      "card_special_invalid"
    when S_RE
      "card_special_redraw"
    when S_EX
      "card_special_exchange"
    when U_SP
      "card_ult_speed"
    when U_AT
      "card_ult_attack"
    when U_MA
      "card_ult_magic_attack"
    when U_MR
      "card_ult_magic_recover"
    end
  end
  
  
  #--------------------------------------------------------------------------
  # ● 內部儲存的結構，根據ID分別
  #--------------------------------------------------------------------------
  @data = {}
  @id_count = 1 # 用來儲存卡片編號
  #============產生資料==============
  
  # 攻擊點數卡
  [3,5,10,15,30].each_with_index do |pts,index|
    new_ins = Game_BattleCard.new
    new_ins.card_type = :attack
    new_ins.card_point = pts
    new_ins.price = [10,15,20,25,40][index]
    add_card(new_ins)
  end
  
  # 防禦點數卡
  [3,5,10,15,30].each_with_index do |pts,index|
    new_ins = Game_BattleCard.new
    new_ins.card_type = :defend
    new_ins.card_point = pts
    new_ins.price = [10,15,20,25,40][index]
    add_card(new_ins)
  end
  
  # 妨礙
  new_ins = Game_BattleCard.new
  new_ins.card_type = :special
  new_ins.card_effect = :interrupt
  new_ins.price = 10
  add_card(new_ins)
  
  # 重新抽卡
  new_ins = Game_BattleCard.new
  new_ins.card_type = :special
  new_ins.card_effect = :deliver
  new_ins.price = 10
  add_card(new_ins)
  
  # 交換牌組
  new_ins = Game_BattleCard.new
  new_ins.card_type = :special
  new_ins.card_effect = :exchange
  new_ins.price = 10
  add_card(new_ins)
  
 # 速度必殺技
  new_ins = Game_BattleCard.new
  new_ins.card_type = :skill
  new_ins.card_skill_type = :speed
  new_ins.price = 30
  add_card(new_ins)

 # 攻擊必殺技
  new_ins = Game_BattleCard.new
  new_ins.card_type = :skill
  new_ins.card_skill_type = :attack
  new_ins.card_effect = :attack_first
  new_ins.price = 30
  add_card(new_ins)

 # 魔法必殺技 - 無視防禦
  new_ins = Game_BattleCard.new
  new_ins.card_type = :skill
  new_ins.card_skill_type = :magic
  new_ins.card_effect = :real_damage
  new_ins.price = 30
  add_card(new_ins)

 # 魔法必殺技 - 恢復
  new_ins = Game_BattleCard.new
  new_ins.card_type = :skill
  new_ins.card_skill_type = :magic
  new_ins.card_effect = :recovery
  new_ins.price = 30
  add_card(new_ins)
  
end  
end
