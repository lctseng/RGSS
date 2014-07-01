#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 時間自動復活機制 ＊

                       for RGSS3

        Ver 1.00   2014.01.29

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   替"ace922(容)"撰寫的特製版本
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、指定回合數到後角色會自動復活
                       二、若角色身上擁有"無法他人復活"狀態，則他人的復活相關技能將對其沒有作用。
                       

   更新紀錄：
    Ver 1.00 ：
    日期：2014.01.29
    摘要：■、最初版本
                ■、功能：                  
                       一、指定回合數到後角色會自動復活
                       二、若角色身上擁有"無法他人復活"狀態，則他人的復活相關技能將對其沒有作用。



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Game_Actor
                          
                        二、此腳本新定義以下類別和模組：
                           ■ Lctseng::AutoRevive
                          

*******************************************************************************************

=end

#encoding:utf-8
#==============================================================================
# ■ Lctseng::AutoRevive
#------------------------------------------------------------------------------
# 　自動復活設定模組
#==============================================================================

module Lctseng
module AutoRevive
  #--------------------------------------------------------------------------
  # ● 設定是否顯示Console 紀錄
  #--------------------------------------------------------------------------
  SHOW_CONSOLE_INFO = true
  #--------------------------------------------------------------------------
  # ● 設定復活所需回合數
  #--------------------------------------------------------------------------
  REVIVE_TURN = 3
  #--------------------------------------------------------------------------
  # ● 設定復活時候，HP與MP的恢復計算公式
  #--------------------------------------------------------------------------
  HP_FORMULA =  " mhp * 0.1 + 10 "
  MP_FORMULA =  " mat + mdf "
  #--------------------------------------------------------------------------
  # ● 設定相關狀態編號
  #--------------------------------------------------------------------------
  DEAD_STATE = 1 # 死亡的狀態
  NO_REVIVE_STATES = [26] # 禁止復活的狀態數列
  
end
end

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


$lctseng_scripts[:auto_revive] = "1.00"

puts "載入腳本：Lctseng - 時間自動復活機制，版本：#{$lctseng_scripts[:auto_revive]}"

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
  # ● 回合結束處理
  #--------------------------------------------------------------------------
  def on_turn_end
    super
    #puts "#{self.name}執行回合結束。" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
    if dead?
      if !@dead_turn 
        @dead_turn = 0
      end
      puts " #{self.name}已經死了#{@dead_turn}個回合..." if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
      if @dead_turn >= Lctseng::AutoRevive::REVIVE_TURN
        puts " #{self.name}復活！清除死亡回合計數！" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
        revive
        remove_state(Lctseng::AutoRevive::DEAD_STATE,true)
        self.hp += eval_formula(Lctseng::AutoRevive::HP_FORMULA)
        self.mp += eval_formula(Lctseng::AutoRevive::MP_FORMULA)
        @dead_turn = 0
      else
        @dead_turn += 1
      end
    else
      @dead_turn = 0
    end
    if alive?
      ## 還活著，自行解除任何限制復活狀態
      Lctseng::AutoRevive::NO_REVIVE_STATES.each do |state_id|
        if state?(state_id)
          puts " #{self.name}還活著，持有#{$data_states[state_id].name}，將自動解除" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
          remove_state(state_id)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 計算公式
  #--------------------------------------------------------------------------
  def eval_formula(formula)
    eval(formula).round rescue 0
  end
  #--------------------------------------------------------------------------
  # ● 計算傷害
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    new_item = item
    if dead? && Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
      new_item = Marshal.load(Marshal.dump(item))
      new_item.damage.formula = "0"
      puts "#{self.name}已死亡且受到復活限制狀態，恢復HP計算強制歸零" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
    end
    super(user,new_item)
  end
  #--------------------------------------------------------------------------
  # ● 更改 HP 
  #--------------------------------------------------------------------------
  def hp=(hp)
    if dead? && Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
      hp = 0 
      puts "#{self.name}已死亡且受到復活限制狀態，HP強制為0" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
    end
    super(hp)
  end
  #--------------------------------------------------------------------------
  # ● 應用“恢復 HP”效果
  #--------------------------------------------------------------------------
  def item_effect_recover_hp(user, item, effect)
    if dead? && Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
      puts " #{self.name}有禁止復活的狀態，恢復HP無效。" if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用“狀態解除”效果
  #--------------------------------------------------------------------------
  def item_effect_remove_state(user, item, effect)
    if effect.data_id == Lctseng::AutoRevive::DEAD_STATE
      if !Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
        super
        if !state?(effect.data_id)
          @dead_turn = 0
          puts "#{self.name}已經復活！清除死亡回合數。"if Lctseng::AutoRevive::SHOW_CONSOLE_INFO
        end
      end
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除狀態
  #--------------------------------------------------------------------------
  def remove_state(state_id,force = false)
    if state_id == Lctseng::AutoRevive::DEAD_STATE
      if force || !Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
        super(state_id)
      end
    else
      super(state_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 死亡
  #--------------------------------------------------------------------------
  def die
    @dead_turn = 0
    @hp = 0
    clear_states_except_revive_limit
    clear_buffs
  end
  #--------------------------------------------------------------------------
  # ● 清除除了死亡限制以外的狀態
  #--------------------------------------------------------------------------
  def clear_states_except_revive_limit
    ## 先記錄死亡狀態資訊
    states = {}
    Lctseng::AutoRevive::NO_REVIVE_STATES.each do |state_id|
      if @states.include?(state_id)
        states[state_id] = [@state_steps[state_id],@state_turns[state_id]]
      end
    end
    ## 呼叫原始的清除方法
    clear_states
    ## 把剛才紀錄的狀態放回去
    states.each_pair do |state_id,data|
      @states.push(state_id)
      @state_steps[state_id] = data[0]
      @state_turns[state_id] = data[1]
    end
    sort_states
  end
  #--------------------------------------------------------------------------
  # ● 判定狀態是否可以附加
  #--------------------------------------------------------------------------
  def state_addable?(state_id)
    if Lctseng::AutoRevive::NO_REVIVE_STATES.include?(state_id)
      $data_states[state_id] && !state_resist?(state_id) &&
      !state_removed?(state_id) && !state_restrict?(state_id)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 測試使用效果
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    if effect.code == EFFECT_REMOVE_STATE && effect.data_id == Lctseng::AutoRevive::DEAD_STATE
      state?(effect.data_id) && !Lctseng::AutoRevive::NO_REVIVE_STATES.any? { |state_id|  state?(state_id) }
    else
      super
    end
  end
  
end
