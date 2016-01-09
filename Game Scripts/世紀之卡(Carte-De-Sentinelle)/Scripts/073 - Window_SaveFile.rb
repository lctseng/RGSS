#encoding:utf-8
#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　存檔畫面和讀檔畫面中顯示存檔文件的窗口。
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :selected                 # 選擇狀態
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #     index : 存檔文件的索引
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(0, index * height, Graphics.width, height)
    @file_index = index
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    name = Vocab::File + " #{@file_index + 1}"
    draw_text(4, 0, 200, line_height, name)
    @name_width = text_size(name).width
    draw_party_characters(152, 58)
    draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
  end
  #--------------------------------------------------------------------------
  # ● 繪制隊伍角色
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_character(data[0], data[1], x + i * 48, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪制游戲時間
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height, header[:playtime_s], 2)
  end
  #--------------------------------------------------------------------------
  # ● 設置選擇狀態
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● 更新光標
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      cursor_rect.set(0, 0, @name_width + 8, line_height)
    else
      cursor_rect.empty
    end
  end
end
