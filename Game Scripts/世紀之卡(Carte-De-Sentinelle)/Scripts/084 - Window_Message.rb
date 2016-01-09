#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　顯示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    self.z = 200
    self.openness = 0
    create_all_windows
    create_back_bitmap
    create_back_sprite
    clear_instance_variables
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的寬度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● 清除實例變量
  #--------------------------------------------------------------------------
  def clear_instance_variables
    @fiber = nil                # 纖程
    @background = 0             # 背景類型
    @position = 2               # 顯示位置
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 清除的標志
  #--------------------------------------------------------------------------
  def clear_flags
    @show_fast = false          # 快進的標志
    @line_show_fast = false     # 行單位快進的標志
    @pause_skip = false         # “不等待輸入”的標志
  end
  #--------------------------------------------------------------------------
  # ● 獲取顯示行數
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_all_windows
    dispose_back_bitmap
    dispose_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_all_windows
    update_back_sprite
    update_fiber
  end
  #--------------------------------------------------------------------------
  # ● 更新纖程
  #--------------------------------------------------------------------------
  def update_fiber
    if @fiber
      @fiber.resume
    elsif $game_message.busy? && !$game_message.scroll_mode
      @fiber = Fiber.new { fiber_main }
      @fiber.resume
    else
      $game_message.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    @gold_window = Window_Gold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = 0
    @gold_window.openness = 0
    @choice_window = Window_ChoiceList.new(self)
    @number_window = Window_NumberInput.new(self)
    @item_window = Window_KeyItem.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 生成背景位圖
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
    rect1 = Rect.new(0, 0, width, 12)
    rect2 = Rect.new(0, 12, width, height - 24)
    rect3 = Rect.new(0, height - 12, width, 12)
    @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
    @back_bitmap.fill_rect(rect2, back_color1)
    @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
  end
  #--------------------------------------------------------------------------
  # ● 獲取背景色 1
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 160)
  end
  #--------------------------------------------------------------------------
  # ● 獲取背景色 2
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
  #--------------------------------------------------------------------------
  # ● 生成背景精靈
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.visible = false
    @back_sprite.z = z - 1
  end
  #--------------------------------------------------------------------------
  # ● 釋放所有窗口
  #--------------------------------------------------------------------------
  def dispose_all_windows
    @gold_window.dispose
    @choice_window.dispose
    @number_window.dispose
    @item_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景位圖
  #--------------------------------------------------------------------------
  def dispose_back_bitmap
    @back_bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景精靈
  #--------------------------------------------------------------------------
  def dispose_back_sprite
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口
  #--------------------------------------------------------------------------
  def update_all_windows
    @gold_window.update
    @choice_window.update
    @number_window.update
    @item_window.update
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精靈
  #--------------------------------------------------------------------------
  def update_back_sprite
    @back_sprite.visible = (@background == 1)
    @back_sprite.y = y
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 處理纖程的主邏輯
  #--------------------------------------------------------------------------
  def fiber_main
    $game_message.visible = true
    update_background
    update_placement
    loop do
      process_all_text if $game_message.has_text?
      process_input
      $game_message.clear
      @gold_window.close
      Fiber.yield
      break unless text_continue?
    end
    close_and_wait
    $game_message.visible = false
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口背景
  #--------------------------------------------------------------------------
  def update_background
    @background = $game_message.background
    self.opacity = @background == 0 ? 255 : 0
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置
  #--------------------------------------------------------------------------
  def update_placement
    @position = $game_message.position
    self.y = @position * (Graphics.height - height) / 2
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
  end
  #--------------------------------------------------------------------------
  # ● 處理所有內容
  #--------------------------------------------------------------------------
  def process_all_text
    open_and_wait
    text = convert_escape_characters($game_message.all_text)
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 輸入處理
  #--------------------------------------------------------------------------
  def process_input
    if $game_message.choice?
      input_choice
    elsif $game_message.num_input?
      input_number
    elsif $game_message.item_choice?
      input_item
    else
      input_pause unless @pause_skip
    end
  end
  #--------------------------------------------------------------------------
  # ● 打開窗口并等待窗口開啟完成
  #--------------------------------------------------------------------------
  def open_and_wait
    open
    Fiber.yield until open?
  end
  #--------------------------------------------------------------------------
  # ● 關閉窗口并等待窗口關閉完成
  #--------------------------------------------------------------------------
  def close_and_wait
    close
    Fiber.yield until all_close?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否所有窗口已全部關閉
  #--------------------------------------------------------------------------
  def all_close?
    close? && @choice_window.close? &&
    @number_window.close? && @item_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 判定文字是否繼續顯示
  #--------------------------------------------------------------------------
  def text_continue?
    $game_message.has_text? && !settings_changed?
  end
  #--------------------------------------------------------------------------
  # ● 判定背景和位置是否被更改
  #--------------------------------------------------------------------------
  def settings_changed?
    @background != $game_message.background ||
    @position != $game_message.position
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 監聽“確定”鍵的按下，更新快進的標志
  #--------------------------------------------------------------------------
  def update_show_fast
    @show_fast = true if Input.trigger?(:C)
  end
  #--------------------------------------------------------------------------
  # ● 輸出一個字符后的等待
  #--------------------------------------------------------------------------
  def wait_for_one_character
    update_show_fast
    Fiber.yield unless @show_fast || @line_show_fast
  end
  #--------------------------------------------------------------------------
  # ● 翻頁處理
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    contents.clear
    draw_face($game_message.face_name, $game_message.face_index, 0, 0)
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  #--------------------------------------------------------------------------
  # ● 獲取換行位置
  #--------------------------------------------------------------------------
  def new_line_x
    $game_message.face_name.empty? ? 0 : 112
  end
  #--------------------------------------------------------------------------
  # ● 普通文字的處理
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    super
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 換行文字的處理
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    @line_show_fast = false
    super
    if need_new_page?(text, pos)
      input_pause
      new_page(text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否需要翻頁
  #--------------------------------------------------------------------------
  def need_new_page?(text, pos)
    pos[:y] + pos[:height] > contents.height && !text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 翻頁文字的處理
  #--------------------------------------------------------------------------
  def process_new_page(text, pos)
    text.slice!(/^\n/)
    input_pause
    new_page(text, pos)
  end
  #--------------------------------------------------------------------------
  # ● 處理控制符指定的圖標繪制
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    super
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # ● 控制符的處理
  #     code : 控制符的實際形式（比如“\C[1]”是“C”）
  #     text : 繪制處理中的字符串緩存（字符串可能會被修改）
  #     pos  : 繪制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    return if !code
    case code.upcase
    when '$'
      @gold_window.open
    when '.'
      wait(15)
    when '|'
      wait(60)
    when '!'
      input_pause
    when '>'
      @line_show_fast = true
    when '<'
      @line_show_fast = false
    when '^'
      @pause_skip = true
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理輸入等待
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) 
    Input.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # ● 處理選項的輸入
  #--------------------------------------------------------------------------
  def input_choice
    @choice_window.start
    Fiber.yield while @choice_window.active
  end
  #--------------------------------------------------------------------------
  # ● 處理數值的輸入
  #--------------------------------------------------------------------------
  def input_number
    @number_window.start
    Fiber.yield while @number_window.active
  end
  #--------------------------------------------------------------------------
  # ● 處理物品的選擇
  #--------------------------------------------------------------------------
  def input_item
    @item_window.start
    Fiber.yield while @item_window.active
  end
end
