#encoding:utf-8
#==============================================================================
# ■ Lctseng::Sprite_TitleCommand
#------------------------------------------------------------------------------
#     標題畫面選項精靈
#==============================================================================
module Lctseng
class Sprite_TitleCommand < Sprite
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :on
  attr_reader :symbol
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include Lctseng::TitleSettings
  include SpriteSensor
  include SpriteSlider
  include SpriteFader
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(index,sym,viewport)
    super(viewport)
    @index = index
    @symbol = sym
    @need_check = true
    @check_result = false
    self.opacity = 0
    create_bitmap
    init_position
    fader_init
    slider_init
    sensor_init
    sensor_set_sense_hover(method(:handler_hover))
    show
  end
  #--------------------------------------------------------------------------
  # ● 初始化位置
  #--------------------------------------------------------------------------
  def init_position
    self.x = Graphics.width - self.width / 1.5
    self.y = 220 + @index *63
  end
  #--------------------------------------------------------------------------
  # ● 顯示
  #--------------------------------------------------------------------------
  def show
    @show_effect = false
    fader_set_fade(255,show_time)
    slider_set_move(current_pos,[Graphics.width - self.width,self.y],show_time)
    sensor_activate
  end
  #--------------------------------------------------------------------------
  # ● 顯示時間
  #--------------------------------------------------------------------------
  def show_time
    COMMON_SHOW_TIME  + @index *2
  end
  #--------------------------------------------------------------------------
  # ● 產生位圖
  #--------------------------------------------------------------------------
  def create_bitmap
    prefix = ''
    case @symbol
    when :start
      prefix = 'Command_Start'
    when :load
      prefix = 'Command_Load'
    when :review
      prefix = 'Command_Review'
    when :credit
      prefix = 'Command_Credit'
    when :exit
      prefix = 'Command_Exit'
    end
    @out = Cache.title(sprintf("%s_out",prefix))
    @in = Cache.title(sprintf("%s_in",prefix))
    @select = Cache.title(sprintf("%s_select",prefix))
    self.bitmap = @out
    @on = false
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    sensor_update
    slider_update
    fader_update
  end
  #--------------------------------------------------------------------------
  # ● 懸浮處理程序
  #--------------------------------------------------------------------------
  def handler_hover(hover)
    if hover
      if !@se_played
        change_to_on
        if @on
          Sound.play_cursor
          @se_played = true
        end
      end
    else
      change_to_off
      @se_played = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理確認
  #--------------------------------------------------------------------------
  def process_ok
    self.bitmap = @select
  end
   #--------------------------------------------------------------------------
  # ● 滑鼠是否在精靈內？
  #--------------------------------------------------------------------------
  def sensor_mouse_in_area?
    if self.bitmap
      Mouse.area?(self.x ,self.y + 5,self.width ,self.height - 10)
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 切換至ON
  #--------------------------------------------------------------------------
  def change_to_on
    #return unless check_command_availble
    @on = true
    self.bitmap = @in
  end
  #--------------------------------------------------------------------------
  # ● 切換至OFF
  #--------------------------------------------------------------------------
  def change_to_off
    @on = false
    self.bitmap = @out
  end
  #--------------------------------------------------------------------------
  # ● 檢查指令是否有效
  #--------------------------------------------------------------------------
  def check_command_availble
    if @need_check
      @need_check = false
      case @symbol
      when :load
        @check_result = DataManager.save_file_exists?
      when :review
        @check_result = false
      when :credit
        @check_result = true
      else
        @check_result = true
      end
    end
    return @check_result
  end
end
end
