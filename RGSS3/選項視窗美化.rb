#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 選項視窗美化 ＊

                       for RGSS3

        Ver 1.1.0   2016.02.17

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123


   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、美化內建的小小選項視窗，變成畫面左上方的大選項


    注意事項：
        ■、若有使用腳本：Lctseng-合併欄位選項，則請將該腳本置於此腳本上方

   更新紀錄：
    Ver 1.0.0 ：
    日期：2014.09.21
    摘要：■、最初版本

    Ver 1.1.0 ：
    日期：2016.02.17
    摘要：
                ■、修正離開商店獲選單時黑框的情形
                ■、隱藏選項視窗的箭頭


    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Window_ChoiceList

                        二、此腳本提供設定模組
                           ■ Lctseng::LargeChoiceWindow



*******************************************************************************************

=end


#encoding:utf-8
#==============================================================================
# ■ Lctseng::LargeChoiceWindow
#------------------------------------------------------------------------------
# 　選項視窗美化設定模組
#==============================================================================

module Lctseng
module LargeChoiceWindow
  #--------------------------------------------------------------------------
  # ● 是否啟用特殊符號辨識(例如：\c[n]、\I[n]等)
  # 啟動後將無法進行文字對齊(強制靠左)
  #--------------------------------------------------------------------------
  TEXT_EX_ENABLE = true
  #--------------------------------------------------------------------------
  # ● 文字對齊樣式，僅限特殊符號關閉時使用
  # 0 = 靠左，1 = 置中，2 = 靠右
  #--------------------------------------------------------------------------
  TEXT_ALIGNMENT = 1
  #--------------------------------------------------------------------------
  # ● 選項視窗位置/大小設定
  #--------------------------------------------------------------------------
  # X 座標
  WINDOW_X = 0
  # Y 座標
  WINDOW_Y = 0
  # 寬
  WINDOW_WIDTH = Graphics.width / 2
  # 高
  WINDOW_HEIGHT = Graphics.height - 200

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

# 避免舊資料遭覆蓋
@_old_val_script_sym = @_script_sym if !@_script_sym.nil?
@_script_sym = :large_choice_window

$lctseng_scripts[@_script_sym] = "1.1.0"

puts "載入腳本：Lctseng - 選項視窗美化，版本：#{$lctseng_scripts[@_script_sym]}"

# 還原舊資料
@_script_sym = @_old_val_script_sym if !@_old_val_script_sym.nil?


#encoding:utf-8
#==============================================================================
# ■ Window_ChoiceList
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“顯示選項”的功能。
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● 初始化對象  - 【修改定義】
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @message_window = message_window
    super(0, 0)
    self.openness = 255
    self.opacity = 0
    self.contents_opacity = 0
    self.x = Lctseng::LargeChoiceWindow::WINDOW_X
    self.y = Lctseng::LargeChoiceWindow::WINDOW_Y
    deactivate
    @select = Sprite.new(self.viewport)
    @select.bitmap = Bitmap.new(contents_width - 8,line_height)
    @select.bitmap.fill_rect(@select.bitmap.rect,Color.new(0,0,0,200))
    @select.visible = false
    @select.opacity = 0
    @select_flash_count = 90
    self.arrows_visible = false
  end
  #--------------------------------------------------------------------------
  # ● 更新打開處理
  #--------------------------------------------------------------------------
  def update_open
    self.contents_opacity += 16
    @opening = false if open?
  end
  #--------------------------------------------------------------------------
  # ● 更新關閉處理
  #--------------------------------------------------------------------------
  def update_close
    self.contents_opacity -= 16
    @closing = false if close?
  end
  #--------------------------------------------------------------------------
  # ● 是否已開啟？
  #--------------------------------------------------------------------------
  def open?
    self.contents_opacity >= 255
  end
  #--------------------------------------------------------------------------
  # ● 是否已關閉？
  #--------------------------------------------------------------------------
  def close?
    self.contents_opacity <= 0
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置 - 【修改定義】
  #--------------------------------------------------------------------------
  def update_placement
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的寬度
  #--------------------------------------------------------------------------
  def window_width
    Lctseng::LargeChoiceWindow::WINDOW_WIDTH
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    Lctseng::LargeChoiceWindow::WINDOW_HEIGHT
  end
  #--------------------------------------------------------------------------
  # ● 計算窗口內容的寬度
  #--------------------------------------------------------------------------
  def contents_width
    window_width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # ● 計算窗口內容的高度
  #--------------------------------------------------------------------------
  def contents_height
    window_height - standard_padding * 3
  end
  #--------------------------------------------------------------------------
  # ● 獲取項目的繪制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    ## 計算間隔高度
    # 可分配的高度量
    remain = contents_height - line_height * row_max
    # 根據index分配數量
    assign = ((remain / row_max)*index).round

    rect.y = (index / col_max * item_height) + assign
    rect
  end
  #--------------------------------------------------------------------------
  # ● 繪制項目
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    contents.fill_rect(rect,back_color)
    if Lctseng::LargeChoiceWindow::TEXT_EX_ENABLE
      draw_text_ex(rect.x, rect.y, command_name(index))
    else
      draw_text(rect, command_name(index) , Lctseng::LargeChoiceWindow::TEXT_ALIGNMENT)
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取背景色
  #--------------------------------------------------------------------------
  def back_color
    Color.new(0, 0, 0, back_opacity)
  end
  #--------------------------------------------------------------------------
  # ● 獲取背景的不透明度
  #--------------------------------------------------------------------------
  def back_opacity
    return 128
  end
   #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
    @select.dispose
  end
   #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    @select.visible = self.visible
    @select.opacity = [self.contents_opacity,self.openness].min
    @select.x = self.x + self.cursor_rect.x + 16
    @select.y = self.y + self.cursor_rect.y + 12
    if @select_flash_count < 0
      @select_flash_count = 30
      @select.flash(Color.new(255,255,255,64),60)
    else
      @select_flash_count -= 1
    end
    @select.update
  end


end
