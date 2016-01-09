#encoding:utf-8
#==============================================================================
# ■ Lctseng::Sprite_ActorSelectButton
#------------------------------------------------------------------------------
#     選單用的切換式按鈕
#==============================================================================
module Lctseng
class Sprite_ActorSelectButton < Sprite_SingleButton
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :selected
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(index,viewport)
    @index = index
    @actor_id = CardBattle.current_actor_id(@index)
    super(get_position,get_bitmap_name,viewport)
    @real_out = @out
    @locked = CardBattle.actor_locked? && index != CardBattle.var_actor_index
    if @locked
      self.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 懸浮處理程序
  #--------------------------------------------------------------------------
  def get_position
    pos = [0,25]
    case @index
    when 0
      pos[0] = 135
    when 1
      pos[0] = 380
    end
    return pos
  end
  #--------------------------------------------------------------------------
  # ● 取得圖片名稱
  #--------------------------------------------------------------------------
  def get_bitmap_name
    "BattleSelectActor_ActorButton#{@actor_id}"
  end
  #--------------------------------------------------------------------------
  # ● 懸浮處理程序
  #--------------------------------------------------------------------------
  def handler_hover(hover)
    if hover && !@locked
      if !@se_played
        change_to_on if !@selected
        if @on
          Sound.play_cursor
          @se_played = true
        end
      end
    else
      if !@selected
        change_to_off
      end
      @se_played = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 進入被選擇
  #--------------------------------------------------------------------------
  def go_selected
    #@selected = true
    @out = @select
  end
  #--------------------------------------------------------------------------
  # ● 離開被選擇
  #--------------------------------------------------------------------------
  def left_selected
    @out = @real_out
    change_to_off
    #@selected = false
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
    return true
  end
end
end
