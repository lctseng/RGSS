#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 事件重疊感應器 ＊

                       for RGSS3

        Ver 1.20   2014.04.14

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版
   原為替替"charlotte051(夏洛特‧聖堂祭司)"撰寫的特製版本
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、玩家、指定事件與感應器事件重疊時，開啟事件的獨立開關D
                       二、可自行設定感應器的觸發開關編號

   更新紀錄：
    Ver 1.00 ：
    日期：2014.04.13
    摘要：一、最初版本
                二、功能：                  
                       一、當玩家與事件重疊時，開啟事件的獨立開關D

    Ver 1.10 ：
    日期：2014.04.13
    摘要：
                一、追加功能：                  
                       一、可自行設定感應器的觸發開關編號
                       二、指定事件也可以觸發感應器
                       
                       
    Ver 1.20 ：
    日期：2014.04.14
    摘要：
                一、追加功能：                  
                       一、可讓獨立開關不會自動關閉
                       
                       

    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           1. Game_Event
                           
                           
                        二、此腳本提供可供設定的模組：
                          1.Lctseng::Overlap_Sensor
                           
                          

*******************************************************************************************

=end

#==============================================================================
# ■ Lctseng::Overlap_Sensor
#------------------------------------------------------------------------------
# 　事件感應器設定用模組
#==============================================================================
module Lctseng
module Overlap_Sensor
  #--------------------------------------------------------------------------
  # ● 定義預設的自用開關編號
  #--------------------------------------------------------------------------
  # 玩家用
  SENSOR_SWITCH_LABEL_PLAYER = "D"
  # 事件用
  SENSOR_SWITCH_LABEL_EVENT = "C"
  #--------------------------------------------------------------------------
  # ● 自用開關是否在離開時自動關閉
  #       注意，如果事件內容太長，則自動關閉要設為false，避免事件被中斷執行
  #--------------------------------------------------------------------------
  SENSOR_SWITCH_AUTO_OFF = true
  
  
end
end



#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#******************************************************************************************



#--------------------------------------------------------------------------
# ★ 紀錄腳本資訊
#--------------------------------------------------------------------------
if !$lctseng_scripts  
  $lctseng_scripts = {}
end
$lctseng_scripts[:overlap_sensor] = "1.20"

puts "載入腳本：Lctseng - 事件重疊感應器，版本：#{$lctseng_scripts[:overlap_sensor]}"


#encoding:utf-8
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　處理事件的類。擁有條件判斷、事件頁的切換、并行處理、執行事件等功能。
#   在 Game_Map 類的內部使用。
#==============================================================================

class Game_Event < Game_Character 
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include Lctseng::Overlap_Sensor
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :enable_sensor
  attr_reader :sensor_trigger
  #--------------------------------------------------------------------------
  # ● 初始化公有成員變量 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_overlap_Init_public_members init_public_members
  #--------------------------------------------------------------------------
  def init_public_members(*args,&block)
    lctseng_for_overlap_Init_public_members(*args,&block)
    @enable_sensor  = false
    @sensor_trigger = false
  end
  #--------------------------------------------------------------------------
  # ● 設置事件頁 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_overlap_Setup_page setup_page
  #--------------------------------------------------------------------------
  def setup_page(*args,&block)
    lctseng_for_overlap_Setup_page(*args,&block)
    @sensor_player_sw_label = SENSOR_SWITCH_LABEL_PLAYER
    @sensor_event_sw_label = SENSOR_SWITCH_LABEL_EVENT
    set_sensor_flag
    @sensor_player_key = [@map_id, @event.id, @sensor_player_sw_label]
    @sensor_event_key = [@map_id, @event.id, @sensor_event_sw_label]
  end
  #--------------------------------------------------------------------------
  # ● 設置啟動感應標誌
  #--------------------------------------------------------------------------
  def set_sensor_flag
    result = false
    trigger = false
    pages = @event.pages
    for page in pages
      now_list = page.list
      for command in now_list
        if command.code == 108
          ## 是否啟用偵測別人
          if command.parameters[0] =~ /<Overlap_Sensor>/i
            result = true
          end #end if
          ## 是否接受偵測
          if command.parameters[0] =~ /<Sensor_Trigger>/i
            trigger = true
          end #end if
          ## 事件用自用開關標示
          if command.parameters[0] =~ /<Sensor_Event_Switch=(.*)>/
            @sensor_event_sw_label = $1
          end #end if
          ## 玩家用自用開關標示
          if command.parameters[0] =~ /<Sensor_Player_Switch=(.*)>/
            @sensor_player_sw_label = $1
          end #end if
          
        end #end if
      end #end for
    end
    @enable_sensor = result
    @sensor_trigger = trigger
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_overlap_Update update
  #--------------------------------------------------------------------------
  def update(*args,&block)
    lctseng_for_overlap_Update(*args,&block)
    if @enable_sensor
      check_sensor
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查感應器
  #--------------------------------------------------------------------------
  def check_sensor
    sensor_player
    sensor_event
  end  
  #--------------------------------------------------------------------------
  # ● 偵測指定事件
  #--------------------------------------------------------------------------
  def sensor_event
    $game_map.events_xy(self.x, self.y).each do |event|
      if event.id != @event.id && event.sensor_trigger # 自己以外的事件才檢查
        $game_self_switches[@sensor_event_key] = true
        return
      end
    end
    if SENSOR_SWITCH_AUTO_OFF && $game_self_switches[@sensor_event_key]
      $game_self_switches[@sensor_event_key] = false 
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 偵測玩家
  #--------------------------------------------------------------------------
  def sensor_player
    if !SENSOR_SWITCH_AUTO_OFF && $game_self_switches[@sensor_player_key]
      return 
    else
      $game_self_switches[@sensor_player_key] = self.pos?($game_player.x,$game_player.y)
    end
  end
end

