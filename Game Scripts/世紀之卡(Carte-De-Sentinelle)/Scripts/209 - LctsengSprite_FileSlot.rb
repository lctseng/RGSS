#encoding:utf-8
#==============================================================================
# ■ Lctseng::Sprite_FileSlot
#------------------------------------------------------------------------------
#     存讀檔格子的精靈
#==============================================================================
module Lctseng
class Sprite_FileSlot < Sprite
  #--------------------------------------------------------------------------
  # ● 常數
  #--------------------------------------------------------------------------
  POSITIONS = [ 
      [40,127],
      [234,127],
      [426,127],
      [40,252],
      [234,252],
      [426,252]
     ]
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :on
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include SpriteSensor
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(index,header,frame_name,viewport)
    super(viewport)
    @index = index
    @header = header
    init_position
    create_bitmap(frame_name)
    sensor_init
    sensor_set_sense_hover(method(:handler_hover))
    sensor_activate
  end
  #--------------------------------------------------------------------------
  # ● 初始化位置
  #--------------------------------------------------------------------------
  def init_position
    set_pos(POSITIONS[@index])
  end
  #--------------------------------------------------------------------------
  # ● 產生位圖
  #--------------------------------------------------------------------------
  def create_bitmap(frame_name)
    f_bit = Cache.picture(frame_name)
    @out = Bitmap.new(f_bit.rect.width ,f_bit.rect.height )
    if @header
      bit = @header[:screen_snap]
      rect = @out.rect.clone
      rect.x += 5
      rect.y += 5
      rect.width  -= 10
      rect.height  -= 10
      @out.stretch_blt(rect, bit, bit.rect) 
    else
      @out.draw_text(0,0,@out.rect.width,@out.rect.height,"沒有存檔",1)
    end
    @out.stretch_blt(@out.rect, f_bit, f_bit.rect) 
    @in = @out.clone
    sel_b = Cache.picture(frame_name + '_select')
    @in.stretch_blt(@in.rect, sel_b, sel_b.rect) 
    self.bitmap = @out
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @in.dispose
    @out.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    sensor_update
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
