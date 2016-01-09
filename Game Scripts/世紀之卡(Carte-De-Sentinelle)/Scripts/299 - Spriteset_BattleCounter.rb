#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_BattleCounter
#------------------------------------------------------------------------------
#   顯示戰鬥計數器的精靈組
#==============================================================================
module CardBattle
class Spriteset_BattleCounter
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(card_set,viewport)
    @viewport = viewport
    @card_set = card_set # 設定所屬卡組
    @current_counter = @card_set.get_battler_counter
    create_sprites
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    cover_pos = @card_set.counter_sprite_pos.clone
    cover_pos[0] += 5
    cover_pos[1] += 5
    # 外框
    @cover = Sprite.new(@viewport)
    @cover.bitmap = Cache.battle('counter_cover')
    @cover.set_pos(cover_pos)
    @cover.z = 30
    
    # 數值
    @number_sprite = Sprite_BattleCounterNumber.new(@viewport)
    @number_sprite.set_pos(cover_pos)
    @number_sprite.set_value(@current_counter)
    @number_sprite.z = 25
    
    # 藍色球
    @defend_ball = Sprite.new(@viewport)
    @defend_ball.bitmap = Cache.battle 'counter_defend_ball'
    @defend_ball.set_pos(@card_set.counter_sprite_pos)
    @defend_ball.z = 10
    @defend_ball.visible =  @card_set.show_defend_ball?
    
    # 紅色球
    @attack_ball = Sprite_Full.new(@viewport)
    @attack_ball.bitmap = Cache.battle 'counter_attack_ball'
    @attack_ball.set_pos(@card_set.counter_sprite_pos)
    @attack_ball.z = 20
    @attack_ball.opacity = 0
    @attack_ball.fader_init
    @attack_shown = false

  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @attack_ball.dispose
    @defend_ball.dispose
    @number_sprite.dispose
    @cover.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_check_value_change
    update_check_icon
    @number_sprite.update
    @attack_ball.fader_update
    @attack_ball.update
  end
  #--------------------------------------------------------------------------
  # ● 更新檢查數值改變
  #--------------------------------------------------------------------------
  def update_check_value_change
    new_counter = @card_set.get_battler_counter
    if @current_counter != new_counter
      set_value_change(@current_counter,new_counter)
      @current_counter = new_counter
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理數值變動
  #--------------------------------------------------------------------------
  def set_value_change(from,to)
    @number_sprite.set_value_fade(from,to)
  end
  #--------------------------------------------------------------------------
  # ● 檢查圖示
  #--------------------------------------------------------------------------
  def update_check_icon
    if @attack_shown
      if !@card_set.show_attack_last?
        @attack_ball.fader_set_fade(0,30)
        @attack_shown = false
      end
    else
      if @card_set.show_attack_last?
        @attack_ball.fader_set_fade(255,30)
        @attack_shown = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def effect?
    @number_sprite.effect?
  end
end
end