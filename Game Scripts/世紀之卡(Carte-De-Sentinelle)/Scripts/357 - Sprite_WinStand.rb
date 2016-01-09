#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_WinStand
#------------------------------------------------------------------------------
# 　顯示戰鬥勝利立繪的精靈
#==============================================================================
module CardBattle
class Sprite_WinStand < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入模組
  #--------------------------------------------------------------------------
  include SpriteFader
  include SpriteSlider
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    create_bitmap
    self.opacity = 0
    self.x = self.width * -1
    self.y = Graphics.height - self.height
    target_x = 0
    # 修正目標x座標
    if target_x + self.width > 385
      target_x = 385 - self.width
    end
    fader_init
    slider_init
    slider_set_move(current_pos,[target_x,self.y],WIN_BASE_PREPARE_TIME)
    fader_set_fade(255,WIN_BASE_PREPARE_TIME)
    start_animation_id(123)
  end
  #--------------------------------------------------------------------------
  # ● 產生圖案
  #--------------------------------------------------------------------------
  def create_bitmap
    id = $game_system.battle_result.actor_id
    self.bitmap = Cache.picture("Actor#{id}_N")
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    fader_update
    slider_update
  end
end
end
