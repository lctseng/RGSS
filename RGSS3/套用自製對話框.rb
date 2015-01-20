#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 套用自製對話框 ＊

                       for RGSS3

        Ver 1.01   2015.01.21

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、可套用另外繪製的對話框(for 544x416解析度)
                       
                       
                       
   更新紀錄：
    Ver 0.1 ：
    日期：2014.10.03
    摘要：
          ■、最初版本
    
    
    Ver 0.2
    日期：2014.10.06
    摘要：
          ■、修正釋放精靈組時變數名稱錯誤的問題

    Ver 0.3
    日期：2014.10.10
    摘要：
          ■、加入自訂哪一個背景模式要顯示對話框的設定

    Ver 1.00
    日期：2014.10.19
    摘要：
          ■、腳本整合發布
          
    Ver 1.01
    日期：2015.01.21
    摘要：
          ■、修正與\LF立繪腳本衝突的問題
          
          
    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Window_Message
                           
                      二、設定模組：
                           ■ Lctseng::TalkFrame
                           
*******************************************************************************************

=end


#encoding:utf-8
#==============================================================================
# ■ Lctseng::TalkFrame
#------------------------------------------------------------------------------
# 　自製對話框設定檔
#==============================================================================
module Lctseng
module TalkFrame
  #--------------------------------------------------------------------------
  # ● 哪些對話模式中要顯示自訂對話框？
  #    0：正常、1：暗化、2：透明
  #    例：[0]    只有正常時會有對話框
  #            [0,1]  正常和暗化時有對話框(註：暗化時的黑背景效果仍在)
  #--------------------------------------------------------------------------
  SHOW_FRAME_BACKGROUND_MODE = [0]
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


$lctseng_scripts[:custom_talk_frame] = "1.00"

puts "載入腳本：Lctseng - 套用自製對話框，版本：#{$lctseng_scripts[:custom_talk_frame]}"


#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　顯示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include Lctseng::TalkFrame
  #--------------------------------------------------------------------------
  # ● 方法重新定義別名
  #--------------------------------------------------------------------------
  unless $@
    alias lctseng_for_custom_talk_frame_Update_all_windows update_all_windows # 更新所有窗口
    alias lctseng_for_custom_talk_frame_Initialize initialize # 初始化對象
    alias lctseng_for_custom_talk_frame_Dispose dispose # 釋放
    alias lctseng_for_custom_talk_frame_Update_placement update_placement # 更新窗口的位置
  end
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  def initialize(*args,&block)
    lctseng_for_custom_talk_frame_Initialize(*args,&block)
    self.opacity = 0
    create_talk_frame_sprite
  end
  #--------------------------------------------------------------------------
  # ● 產生對話視窗精靈
  #--------------------------------------------------------------------------
  def create_talk_frame_sprite
    @blank_frame_sprite = Sprite.new
    @blank_frame_sprite.bitmap = Cache.picture("talkframe")
    @blank_frame_sprite.oy = @blank_frame_sprite.bitmap.height
    @blank_frame_sprite.y = Graphics.height
    @blank_frame_sprite.z = 100
    @blank_frame_sprite.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 釋放 - 重新定義
  #--------------------------------------------------------------------------
  def dispose(*args,&block)
    dispose_talk_frame_sprite
    lctseng_for_custom_talk_frame_Dispose(*args,&block)
  end
  #--------------------------------------------------------------------------
  # ● 釋放對話視窗精靈
  #--------------------------------------------------------------------------
  def dispose_talk_frame_sprite
    @blank_frame_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口 - 重新定義
  #--------------------------------------------------------------------------
  def update_all_windows
    lctseng_for_custom_talk_frame_Update_all_windows
    if self.visible
      @blank_frame_sprite.opacity = self.openness
    else
      @blank_frame_sprite.opacity = 0
    end
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精靈 - 修改定義
  #--------------------------------------------------------------------------
  def update_back_sprite
    if self.visible &&@background > 0  
      @back_sprite.visible = (@background == 1)
      @back_sprite.y = y
      @back_sprite.opacity = openness
    else
      @back_sprite.visible = false
      @back_sprite.opacity = 0
    end
    @back_sprite.update
    @blank_frame_sprite.visible = SHOW_FRAME_BACKGROUND_MODE.include?(@background)
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精靈位置
  #--------------------------------------------------------------------------
  def update_background_sprite_placement
    case @position
    when 0
      @blank_frame_sprite.y = @blank_frame_sprite.height
      self.y = @blank_frame_sprite.y - 120
    when 1
      @blank_frame_sprite.y = (@blank_frame_sprite.height + Graphics.height) / 2
      self.y = @blank_frame_sprite.y - 115
    when 2
      @blank_frame_sprite.y = Graphics.height
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置 - 重新定義
  #--------------------------------------------------------------------------
  def update_placement
    lctseng_for_custom_talk_frame_Update_placement
    update_background_sprite_placement
  end
end

