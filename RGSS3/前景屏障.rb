#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 前景視野屏障 ＊

                       for RGSS3

        Ver 1.1.0   2015.12.22

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、前景多一層視野屏障，可模擬洞窟視野

   更新紀錄：
    Ver 1.0.0 ：
    日期：2013.02.10
    摘要：一、最初版本

    Ver 1.1.0 ：
    日期：2015.12.22
    摘要：一、新增Z座標調整



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.Game_Interpreter
                          2.Game_Picture
                          3.Game_Map
                          4.Scene_Map
                          5.Sprite_Picture

                        二、可供修改的模組：
                          1.Lctseng_Dark_Sight_Settings



*******************************************************************************************

=end

module Lctseng_Dark_Sight_Settings

  # 屏障淡入時間
  DEFAULT_FADEIN_DURATION = 120
  # 屏障淡出時間
  DEFAULT_FADEOUT_DURATION = 120

  PICTURE_Z = 500

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
_sym = :dark_sight
$lctseng_scripts[_sym] = "1.1.0"

puts "載入腳本：Lctseng - 前景視野屏障，版本：#{$lctseng_scripts[_sym]}"


#==============================================================================
# ■ Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 顯示視野屏障
  #--------------------------------------------------------------------------
  def show_dark_sight(duration = Lctseng_Dark_Sight_Settings::DEFAULT_FADEOUT_DURATION)
    $game_map.dark_sight_fadein_speed = 255.0 / duration
  end
  #--------------------------------------------------------------------------
  # ● 消去視野屏障
  #--------------------------------------------------------------------------
  def hide_dark_sight(duration = Lctseng_Dark_Sight_Settings::DEFAULT_FADEIN_DURATION)
    $game_map.dark_sight_fadeout_speed = 255.0 / duration
  end
  #--------------------------------------------------------------------------
  # ● 暫時性解除迷霧
  #--------------------------------------------------------------------------
  def force_white_for_temp
    $game_map.dark_sight_fadeout_speed = 255.0 / 10
    $game_map.force_white_time = 60
    $game_map.dark_sight_fadein_speed = 255.0 / 300
  end


  def change_sight_picture(filename)
    $game_map.screen.pictures[0].show(filename ,  1 ,$game_player.screen_x,$game_player.screen_y, 100, 100, 0, 0)
  end

end##end class

#encoding:utf-8
#==============================================================================
# ■ Game_Picture
#------------------------------------------------------------------------------
# 　管理圖片的類。本類在 Game_Pictures 類的內部使用，當需要特定編號的圖片時才
#   生成實例。
#==============================================================================

class Game_Picture
  attr_accessor :opacity
  #--------------------------------------------------------------------------
  # ● 改變座標
  #--------------------------------------------------------------------------
  def move_xy(x,y)
    @x = x
    @y = y
  end
end

#encoding:utf-8
#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　管理地圖的類。擁有卷動地圖以及判斷通行度的功能。
#   本類的實例請參考 $game_map 。
#==============================================================================

class Game_Map
  attr_writer :dark_sight_fadein_speed
  attr_writer :dark_sight_fadeout_speed
  attr_accessor :force_white_time
  #--------------------------------------------------------------------------
  # ● 更新畫面 - 重新定義
  #     main : 事件解釋器更新的標志
  #--------------------------------------------------------------------------
  alias lctseng_update update
  #--------------------------------------------------------------------------
  def update(main = false)
    lctseng_update(main)
    update_dark_sight_position
    update_force_white_time
    update_dark_screen_fadein
    update_dark_screen_fadeout
  end
  #--------------------------------------------------------------------------
  # ● 更新視野屏障的位置
  #--------------------------------------------------------------------------
  def update_dark_sight_position
    screen.pictures[0].move_xy($game_player.screen_x,$game_player.screen_y )
  end
  #--------------------------------------------------------------------------
  # ● 更新強制開視野時間
  #--------------------------------------------------------------------------
  def update_force_white_time
    @force_white_time = 0 unless @force_white_time
    @force_white_time -= 1 if @force_white_time > 0
  end
  #--------------------------------------------------------------------------
  # ● 更新視野屏障淡入
  #--------------------------------------------------------------------------
  def update_dark_screen_fadein
    return if @force_white_time > 0
    if @dark_sight_fadein_speed && @dark_sight_fadein_speed > 0
       screen.pictures[0].opacity += @dark_sight_fadein_speed
       if screen.pictures[0].opacity >= 255
         @dark_sight_fadein_speed = 0.0
       end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新視野屏障淡出
  #--------------------------------------------------------------------------
  def update_dark_screen_fadeout
    if @dark_sight_fadeout_speed && @dark_sight_fadeout_speed > 0
       screen.pictures[0].opacity -= @dark_sight_fadeout_speed
       if screen.pictures[0].opacity <= 0
         @dark_sight_fadeout_speed = 0.0
       end
    end

  end
end


 #$game_map.screen.pictures[0].move_xy(screen_x,screen_y ) rescue nil #if $game_map.screen.pictures[0]


 #==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  alias lctseng_start_for_dark_sight start
  #--------------------------------------------------------------------------
  def start
    lctseng_start_for_dark_sight
    if $game_map.screen.pictures[0].name == ""
      $game_map.screen.pictures[0].show("Dark_Sight",  1 ,$game_player.screen_x,$game_player.screen_y, 100, 100, 0, 0)
    end

  end
end


#encoding:utf-8
#==============================================================================
# ■ Sprite_Picture
#------------------------------------------------------------------------------
# 　顯示圖片用的精靈。根據 Game_Picture 類的實例的狀態自動變化。
#==============================================================================

class Sprite_Picture
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  alias lctseng_dark_sight_update_position update_position
  def update_position(*args,&block)
    if @picture.number == 0
      self.x = @picture.x
      self.y = @picture.y
      self.z = Lctseng_Dark_Sight_Settings::PICTURE_Z
    else
      lctseng_dark_sight_update_position(*args,&block)
    end

  end

end
