#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 顯示事件名稱-普通版 ＊

                       for RGSS3

        Ver 0.3   2013.01.23

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、顯示地圖上事件的名稱

   更新紀錄：
    Ver 0.1 ：
    日期：2013.01.17
    摘要：一、最初版本
    
    
   更新紀錄：
    Ver 0.2 ：
    日期：2013.01.17
    摘要：一、修正更換地圖時舊名稱ID無法即時刷新的問題(感謝巴友 aries0411 發現此問題)

    
   更新紀錄：
    Ver 0.3 ：
    日期：2013.01.23
    摘要：一、修正一開始的事件頁沒有名稱時以後無法產生名稱圖像的錯誤

    
    
    
    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.Game_Interpreter
                          2.Game_System
                          3.Game_Event
                          4.Spriteset_Map
                          
                        二、新增的類別：
                          1.Sprite_EventName
                          
                        三、可供修改的模組
                          1.設定字形與位置：Lctseng_Event_Name_Setting_For_Normal_Version
                          
                          

*******************************************************************************************

=end

module Lctseng_Event_Name_Setting_For_Normal_Version
  
  #--------------------------------------------------------------------------
  # ● 字型設定
  #--------------------------------------------------------------------------
  Draw_Font = Font.new 
  Draw_Font.name = "標楷體",'Microsoft JhengHei' #字體名稱
  Draw_Font.size = 16 #字體大小
  Draw_Font.color = (Color.new(25,255,255,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Draw_Font.bold = true #是否粗體字
  Draw_Font.italic = false #是否斜體字
  Draw_Font.outline = true #是否繪製文字邊緣
  Draw_Font.shadow = true #是否繪製陰影
  Draw_Font.out_color = (Color.new(100,100,100,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)
  #--------------------------------------------------------------------------
  # ● 位置調整
  #--------------------------------------------------------------------------
  Show_X_Adjust = 0 #顯示框的X座標調整
  Show_Y_Adjust = 0 #顯示框的Y座標調整
  Show_Z_Adjust = 0 #顯示框的Z座標調整
  
  
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
$lctseng_scripts[:event_name] = "0.3"

puts "載入腳本：Lctseng - 顯示事件名稱，版本：#{$lctseng_scripts[:event_name]}"



#==============================================================================
# ■ Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 啟動事件名稱全部隱藏
  #--------------------------------------------------------------------------
  def hide_all_event_names
    $game_system.force_hide_all_event_name = true
  end
  #--------------------------------------------------------------------------
  # ● 關閉事件名稱全部隱藏
  #--------------------------------------------------------------------------
  def show_all_event_names
    $game_system.force_hide_all_event_name = false
  end
  
end##end class

#encoding:utf-8
#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　處理系統附屬數據的類。保存存檔和菜單的禁止狀態之類的數據。
#   本類的實例請參考 $game_system 。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :force_hide_all_event_name
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Initialize initialize
  #--------------------------------------------------------------------------
  def initialize
    lctseng_for_event_name_Initialize
    @force_hide_all_event_name = false
  end
end

#encoding:utf-8
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　處理事件的類。擁有條件判斷、事件頁的切換、并行處理、執行事件等功能。
#   在 Game_Map 類的內部使用。
#==============================================================================

class Game_Event < Game_Character    
  attr_accessor :need_redraw_name
  #--------------------------------------------------------------------------
  # ● 初始化公有成員變量 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Init_public_members init_public_members
  #--------------------------------------------------------------------------
  def init_public_members
    lctseng_for_event_name_Init_public_members
    @current_ok_name = ""
    @need_redraw_name  = false
  end
  #--------------------------------------------------------------------------
  # ● 設置事件頁 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Setup_page setup_page
  #--------------------------------------------------------------------------
  def setup_page(new_page)
    lctseng_for_event_name_Setup_page(new_page)
    @current_ok_name = excute_if_need_name_in_the_comment_and_set_show_name
    @need_redraw_name  = true
  end
  #--------------------------------------------------------------------------
  # ● 是否需要產生名稱框精靈
  #--------------------------------------------------------------------------
  def need_name_block?
    return detect_all_need_names
  end
  #--------------------------------------------------------------------------
  # ● 名稱是否可見？(普通版)
  #--------------------------------------------------------------------------
  def name_visible?
    return @activate_event_name
  end
  #--------------------------------------------------------------------------
  # ● 取得名稱，若有的話
  #--------------------------------------------------------------------------
  def if_need_name_in_the_comment_and_get_show_name
    @current_ok_name
  end
  #--------------------------------------------------------------------------
  # ● 偵測事件是否有任何一頁有要求名稱
  #--------------------------------------------------------------------------
  def detect_all_need_names
    for page in @event.pages
      now_list = page.list
      for command in now_list
        if command.code == 108
          ## 匹配出名稱
          if command.parameters[0] =~ /<Show_Event_Name =(.*)>/
            return true
          end #end if
        end #end if
      end #end for
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 偵測普通NPC在特定事件頁的註釋中是不是有名稱需求
  #      並取得名稱框的文字
  #      若是ARPG事件，則直接取用事件名稱
  #--------------------------------------------------------------------------
  def excute_if_need_name_in_the_comment_and_set_show_name
    @activate_event_name = false
    begin
      now_list = @page.list
    rescue
      return ''
    end
    for command in now_list
      if command.code == 108
        ## 匹配出名稱
        if command.parameters[0] =~ /<Show_Event_Name =(.*)>/
          @activate_event_name = true
          return $1
        end #end if
      end #end if
    end #end for
    return ''
  end #end def
  
  
end

#encoding:utf-8
#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　處理地圖畫面精靈和圖塊的類。本類在 Scene_Map 類的內部使用。
#==============================================================================


class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Initialize initialize
  #--------------------------------------------------------------------------
  def initialize
    @event_name_sprites = []
    lctseng_for_event_name_Initialize
    create_event_name_sprites
  end
  #--------------------------------------------------------------------------
  # ● 生成事件名稱精靈
  #--------------------------------------------------------------------------
  def create_event_name_sprites
    @event_name_sprites = []
    $game_map.events.values.each do |event|
      if event.need_name_block?
        @event_name_sprites.push(Sprite_EventName.new(event,@viewport1))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新事件名稱
  #--------------------------------------------------------------------------
  def refresh_event_name
    dispose_event_name_sprites
    create_event_name_sprites
  end  
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Dispose dispose
  #--------------------------------------------------------------------------
  def dispose
    lctseng_for_event_name_Dispose
    dispose_event_name_sprites
  end
  #--------------------------------------------------------------------------
  # ● 釋放事件名稱精靈
  #--------------------------------------------------------------------------
  def dispose_event_name_sprites
    @event_name_sprites.compact.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  alias lctseng_for_event_name_Update update
  #--------------------------------------------------------------------------
  def update
    refresh_event_name if @map_id != $game_map.map_id
    update_event_name_sprites
    lctseng_for_event_name_Update
  end
  #--------------------------------------------------------------------------
  # ● 更新事件名稱精靈
  #--------------------------------------------------------------------------
  def update_event_name_sprites
    @event_name_sprites.each {|sprite| sprite.update }
  end
end

#encoding:utf-8
#==============================================================================
# ■ Sprite_EventName
#==============================================================================

class Sprite_EventName < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化對象 event :  Game_Event
  #--------------------------------------------------------------------------
  def initialize(event,viewport = nil)
    super(viewport)
    self.visible = false
    @redrawing = false
    @event = event
    @current_name= @event.if_need_name_in_the_comment_and_get_show_name
    create_bitmap
    redraw
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 生成位圖
  #--------------------------------------------------------------------------
  def create_bitmap
    width = @current_name.size * Lctseng_Event_Name_Setting_For_Normal_Version::Draw_Font.size * 2
    if width <=0
      width = 1
    end
    self.bitmap = Bitmap.new(width, Lctseng_Event_Name_Setting_For_Normal_Version::Draw_Font.size)
    self.bitmap.font = Lctseng_Event_Name_Setting_For_Normal_Version::Draw_Font
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_position
    update_visibility
    update_check_and_redraw
  end
  #--------------------------------------------------------------------------
  # ● 更新檢查
  #--------------------------------------------------------------------------
  def update_check_and_redraw
    if @event.need_redraw_name
      @event.need_redraw_name = false
      new_name = @event.if_need_name_in_the_comment_and_get_show_name
      if @current_name != new_name
        @current_name = new_name
        redraw
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 重繪
  #--------------------------------------------------------------------------
  def redraw
    @redrawing = true
    self.bitmap.dispose
    create_bitmap
    self.bitmap.draw_text(self.bitmap.rect,@current_name, 1)
    update_position
    @redrawing = false
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    self.x = @event.screen_x - self.bitmap.width / 2 + Lctseng_Event_Name_Setting_For_Normal_Version::Show_X_Adjust
    self.y = @event.screen_y + 10 + Lctseng_Event_Name_Setting_For_Normal_Version::Show_Y_Adjust
    self.z = 20 + Lctseng_Event_Name_Setting_For_Normal_Version::Show_Z_Adjust
  end
  #--------------------------------------------------------------------------
  # ● 更新可視狀態
  #--------------------------------------------------------------------------
  def update_visibility
    if $game_system.force_hide_all_event_name
      self.visible = false
    else
      self.visible = @event.name_visible?
    end
  end

end
