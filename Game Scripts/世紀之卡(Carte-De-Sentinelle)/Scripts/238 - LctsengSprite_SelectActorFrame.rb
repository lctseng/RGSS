#encoding:utf-8
#==============================================================================
# ■ Lctseng::Sprite_SelectActorFrame
#------------------------------------------------------------------------------
# 　顯示戰鬥勝利基底的精靈
#==============================================================================
module Lctseng
class Sprite_SelectActorFrame < Sprite_Base
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
    fader_init
    slider_init
    @s_info = Sprite_SelectActorInfo.new(self,viewport)
  end
  #--------------------------------------------------------------------------
  # ● 產生圖案
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Cache.picture('BattleSelectActor_Ability')
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    fader_update
    slider_update
    @s_info.update
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @s_info.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 顯示資訊
  #--------------------------------------------------------------------------
  def show_info
    @s_info.show_info(@actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 顯示
  #--------------------------------------------------------------------------
  def show(id)
    @actor_id = id
    self.opacity = 0
    @s_info.clear
    self.x = Graphics.width - 50
    self.y = Graphics.height - self.height
    start_animation_id(124)
    slider_set_move(current_pos,[Graphics.width - self.width ,self.y],20)
    fader_set_fade(255,20)
    fader_set_post_handler(method(:show_info))
  end
end
end
