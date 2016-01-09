#encoding:utf-8
#==============================================================================
# ■ Lctseng::Sprite_MiniMenuButton
#------------------------------------------------------------------------------
#     選單用的切換式按鈕
#==============================================================================
module Lctseng
class Sprite_MiniMenuButton < Sprite_SingleButton
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :selected
  attr_reader :symbol
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(sym,position,b_name,viewport)
    @symbol = sym
    super(position,b_name,viewport)
  end
  #--------------------------------------------------------------------------
  # ● 懸浮處理程序
  #--------------------------------------------------------------------------
  def handler_hover(hover)
    if hover
      $game_system.disable_message_continue = true
      if !@se_played
        change_to_on if !@selected
        if @on
          Sound.play_cursor
          @se_played = true
        end
      end
    else
      if !@selected
        $game_system.disable_message_continue = false
        change_to_off
      end
      @se_played = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    if check_command_availble
      self.visible = true
    else
      self.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理確認
  #--------------------------------------------------------------------------
  def process_ok
    if @selected
      puts "關閉選擇"
      @selected = false
      self.bitmap = @in
    else
      @selected = true
      self.bitmap = @select
    end
  end
  #--------------------------------------------------------------------------
  # ● 檢查指令是否有效
  #--------------------------------------------------------------------------
  def check_command_availble
    return !$game_system.save_disabled && !$game_map.display_name.empty?
  end
end
end
