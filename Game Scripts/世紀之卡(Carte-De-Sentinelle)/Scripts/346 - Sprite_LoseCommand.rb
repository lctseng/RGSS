#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_LoseCommand
#------------------------------------------------------------------------------
# 　顯示失敗選項的精靈
#==============================================================================
module CardBattle
class Sprite_LoseCommand < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入模組
  #--------------------------------------------------------------------------
  include SpriteFader
  include SpriteSlider
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :active
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(sym,viewport = nil)
    super(viewport)
    @symbol = sym
    @active = false
    @active_flash = false
    @flash_on = true
    @has_in = false
    self.opacity = 0
    create_bitmap
    fader_init
    slider_init
  end
  #--------------------------------------------------------------------------
  # ● 產生圖片
  #--------------------------------------------------------------------------
  def create_bitmap
    name = @symbol.id2name
    self.bitmap = Cache.lose(name)
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    fader_update
    slider_update
    update_flash
    update_mouse_in_area?
  end
  #--------------------------------------------------------------------------
  # ● 更新閃爍
  #--------------------------------------------------------------------------
  def update_flash
    return if !@active_flash || fader_fading?
    if @flash_on
      @flash_on = false
      fader_set_fade(160,LOSE_CMD_FLASH_INTERVAL)
    else
      @flash_on = true
      fader_set_fade(250,LOSE_CMD_FLASH_INTERVAL)
    end
  end
  #--------------------------------------------------------------------------
  # ● 快轉
  #--------------------------------------------------------------------------
  def fast_forward
    activate
  end
  #--------------------------------------------------------------------------
  # ● 啟用
  #--------------------------------------------------------------------------
  def activate
    puts "指令開啟：#{@symbol}"
    @active = true
    process_show
  end

  #--------------------------------------------------------------------------
  # ● 處理顯示
  #--------------------------------------------------------------------------
  def process_show
    to_y = 402
    from = [0,to_y]
    to = [0,to_y]
    case @symbol
    when :cmd_again
      from[0] = 50
      to[0] = 95
    when :cmd_title
      from[0] = 450
      to[0] = 405
    end
    slider_set_move(from,to,30)
    fader_set_fade(255,30)
    fader_set_post_handler(Proc.new { @active_flash = true })
  end
  #--------------------------------------------------------------------------
  # ● 更新滑鼠判定
  #--------------------------------------------------------------------------
  def  update_mouse_in_area?
    result = mouse_in_area?
    if result
      do_flash = false
      if !@has_in
        @has_in = true
        do_flash = true
      else
        if @select_flash_interval > 0
          @select_flash_interval -= 1
        else
          do_flash = true
        end
      end
      if do_flash
        @select_flash_interval = LOSE_CMD_SELECT_INTERVAL
        self.flash(Color.new(255,255,255),30)
      end
    else
      @has_in = false
    end
  end
  
end
end
