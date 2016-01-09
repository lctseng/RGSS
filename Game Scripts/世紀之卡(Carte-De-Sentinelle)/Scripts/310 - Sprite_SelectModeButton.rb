#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_SelectModeButton
#------------------------------------------------------------------------------
#     選擇模式的按鈕精靈
#==============================================================================
module CardBattle
class Sprite_SelectModeButton < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入淡入淡出模組
  #--------------------------------------------------------------------------
  include SpriteFader
  include SpriteSensor
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :mode_select_handler
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(symbol,viewport)
    super(viewport)
    self.opacity = 0
    @symbol = symbol
    create_bitmap
    self.z = 100
    fader_init
    sensor_init
    sensor_set_sense_hover(method(:hover_handler))
    @mode_select_handler = nil
  end
  #--------------------------------------------------------------------------
  # ● 產生點陣圖
  #--------------------------------------------------------------------------
  def create_bitmap
    case @symbol
    when :attack
      @bitmap_in = Cache.battle("battle_btn_atk_selected")
      @bitmap_out = Cache.battle("battle_btn_atk")
      self.x = 122
      self.y = 185
    when :defend
      @bitmap_in = Cache.battle("battle_btn_def_selected")
      @bitmap_out = Cache.battle("battle_btn_def")
      self.x = 374
      self.y = 185
    when :ok
      @bitmap_in = Cache.battle("battle_btn_enter_selected")
      @bitmap_out = Cache.battle("battle_btn_enter")
      self.x = 187
      self.y = 240
    when :cancel
      @bitmap_in = Cache.battle("battle_btn_cancel_selected")
      @bitmap_out = Cache.battle("battle_btn_cancel")
      self.x = 352
      self.y = 240
    end
    
    self.bitmap = @bitmap_in
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    fader_update
    sensor_update
  end
  #--------------------------------------------------------------------------
  # ● 呼叫感應器的檢查方法 - 重新定義
  #--------------------------------------------------------------------------
  def sensor_call_input
    if Input.trigger?(:C)
      @sensor_input_handler.call(@symbol)
    end
  end
  #--------------------------------------------------------------------------
  # ● 懸浮處理程序
  #--------------------------------------------------------------------------
  def hover_handler(hover)
    if hover
      #puts "進入#{@symbol}"
      self.bitmap = @bitmap_in
    else
      self.bitmap = @bitmap_out
    end
  end
end
end
