=begin



   ＊ Lctseng - 戰鬥結束後自動事件執行＊

                       for RGSS3

        Ver 1.0.0   2015.08.14

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   ＊注意！請將此腳本至於所有外加腳本的最前端＊
   原因：改寫大量內建腳本，無使用alias

   主要功能：
                       一、戰鬥勝利/失敗/逃跑後，可以執行某一個公共事件

   更新紀錄：
    Ver 1.0.0 ：
    日期：2015.08.14
    摘要：一、最初版本


    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          ■ BattleManager
                          ■ Game_Troop
                          ■ Scene_Battle

                        二、此腳本提供設定模組
                           ■ Lctseng::EventAfterBattle



=end


#encoding:utf-8
#==============================================================================
# ■ Lctseng::EventAfterBattle
#------------------------------------------------------------------------------
# 　戰鬥後事件設定模組
#==============================================================================

module Lctseng
module EventAfterBattle
  #--------------------------------------------------------------------------
  # ● 戰鬥勝利後，要取得哪一個變數的內容做為公共事件ID
  # 範例中，假設此時變數5的內容是10，在戰勝後就會自動執行第10號公共事件
  # 若該變數的內容是0，則甚麼事也不會發生
  #--------------------------------------------------------------------------
  VICTORY_VARIABLE_ID = 5
  #--------------------------------------------------------------------------
  # ● 戰鬥失敗後
  #--------------------------------------------------------------------------
  DEFEAT_VARIABLE_ID = 6
  #--------------------------------------------------------------------------
  # ● 戰鬥逃走後
  #--------------------------------------------------------------------------
  ESCAPE_VARIABLE_ID = 7
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
_sym = :event_after_battle
$lctseng_scripts[_sym] = "1.0.0"

puts "載入腳本：Lctseng - 戰鬥結束後自動事件執行，版本：#{$lctseng_scripts[_sym]}"





#encoding:utf-8
#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戰鬥過程管理器。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 勝利時的處理 - 修改定義
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.scene.process_victory_event
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 逃走時的處理 - 修改定義
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      SceneManager.scene.process_escape_event
      process_abort
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # ● 全滅時的處理 - 修改定義
  #--------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    SceneManager.scene.process_defeat_event
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
end

#encoding:utf-8
#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　管理敵群和戰鬥相關資料的類，也可執行如戰鬥事件管理之類的功能。
#   本類的實例請參考 $game_troop 。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 設置事件
  #--------------------------------------------------------------------------
  def setup_event(ev_id)
    event = $data_common_events[ev_id]
    @interpreter.setup(event.list)
  end
end

#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　戰斗畫面
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 處理戰鬥勝利事件
  #--------------------------------------------------------------------------
  def process_victory_event
    ev_id = $game_variables[Lctseng::EventAfterBattle::VICTORY_VARIABLE_ID]
    process_battle_force_event(ev_id)
  end
  #--------------------------------------------------------------------------
  # ● 處理戰鬥失敗事件
  #--------------------------------------------------------------------------
  def process_defeat_event
    ev_id = $game_variables[Lctseng::EventAfterBattle::DEFEAT_VARIABLE_ID]
    process_battle_force_event(ev_id)
  end
  #--------------------------------------------------------------------------
  # ● 處理戰鬥逃跑事件
  #--------------------------------------------------------------------------
  def process_escape_event
    ev_id = $game_variables[Lctseng::EventAfterBattle::ESCAPE_VARIABLE_ID]
    process_battle_force_event(ev_id)
  end
  #--------------------------------------------------------------------------
  # ● 處理戰鬥強制事件
  #--------------------------------------------------------------------------
  def process_battle_force_event(ev_id)
    return if ev_id <= 0
    $game_troop.setup_event(ev_id)
    while true
      $game_troop.interpreter.update
      wait_for_message
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
end
