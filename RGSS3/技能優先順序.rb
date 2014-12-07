#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 技能優先順序 ＊

                       for RGSS3

        Ver 0.1   2014.12.08

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   替"chanszeman10(Sze)"撰寫的特製版本
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、技能/道具的"速度修正"將決定真實行動順序，如果此數值相同才檢查敏捷等數值
                       

   更新紀錄：
    Ver 0.1 ：
    日期：2014.12.08
    摘要：■、最初版本



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ BattleManager
                           ■ Game_Battler
                           ■ Game_Action
                          
                          

*******************************************************************************************

=end

#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************

#--------------------------------------------------------------------------
# ★ 紀錄腳本資訊
#--------------------------------------------------------------------------
if !$lctseng_scripts  
  $lctseng_scripts = {}
end

# 避免舊資料遭覆蓋
@_old_val_script_sym = @_script_sym if !@_script_sym.nil?
@_script_sym = :item_speed_first

$lctseng_scripts[@_script_sym] = "0.1"

puts "載入腳本：Lctseng - 技能優先順序，版本：#{$lctseng_scripts[@_script_sym]}"

# 還原舊資料
@_script_sym = @_old_val_script_sym if !@_old_val_script_sym.nil?




#encoding:utf-8
#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戰鬥過程管理器。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 生成行動順序 - 修改，修改速度計算公式
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += $game_party.members unless @surprise
    @action_battlers += $game_troop.members unless @preemptive
    @action_battlers.each {|battler| battler.make_speed }
    @action_battlers.sort! {|a,b| speed_compare(a,b) } # 公式修改
  end
  #--------------------------------------------------------------------------
  # ● 速度比較
  #--------------------------------------------------------------------------
  def self.speed_compare(a,b)
    if a.min_item_speed == b.min_item_speed
      puts "#{a.name}使用的技能與#{b.name}相同優先權(皆為#{a.min_item_speed})，比較一般速度"
      return b.speed - a.speed
    else
      puts "#{a.name}的技能優先：#{a.min_item_speed}；#{b.name}的技能優先：#{b.min_item_speed}"
      return b.min_item_speed - a.min_item_speed
    end
  end

end

#encoding:utf-8
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　處理戰鬥者的類。Game_Actor 和 Game_Enemy 類的父類。
#==============================================================================

class Game_Battler < Game_BattlerBase
  
  attr_accessor :min_item_speed
  #--------------------------------------------------------------------------
  # ● 決定行動速度 - 修改，紀錄道具/技能速度
  #--------------------------------------------------------------------------
  def make_speed
    @min_item_speed = @actions.collect { |action| action.item ? action.item.speed : 0}.min
    puts "#{self.name}的動作數：#{@actions.size}，最小速度：#{@min_item_speed}"
    @speed = @actions.collect {|action| action.speed }.min || 0
  end
end


#encoding:utf-8
#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　處理戰鬥中的行動的類。本類在 Game_Battler 類的內部使用。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 計算行動速度 - 修改，移除道具/技能計算
  #--------------------------------------------------------------------------
  def speed
    speed = subject.agi + rand(5 + subject.agi / 4)
    speed += subject.atk_speed if attack?
    speed
  end
end
