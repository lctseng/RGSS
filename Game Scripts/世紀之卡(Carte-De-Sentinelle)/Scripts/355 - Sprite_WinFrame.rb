#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_WinFrame
#------------------------------------------------------------------------------
# 　顯示戰鬥勝利基底的精靈
#==============================================================================
module CardBattle
class Sprite_WinFrame < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入模組
  #--------------------------------------------------------------------------
  include SpriteFader
  include SpriteSlider
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(master,viewport = nil)
    super(viewport)
    @master = master
    create_bitmap
    self.opacity = 0
    self.x = 251
    self.y = -20
    self.z = 10
    fader_init
    slider_init
    slider_set_move(current_pos,[self.x,13],WIN_BASE_PREPARE_TIME)
    fader_set_fade(255,WIN_BASE_PREPARE_TIME)
    fader_set_post_handler(method(:show_info))
    @s_info = Sprite_WinInfo.new(@master,self,viewport)
    start_animation_id(124)
  end
  #--------------------------------------------------------------------------
  # ● 產生圖案
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Cache.win('Frame').clone
    id = $game_system.battle_result.actor_id
    b_name = Cache.win("Actor#{id}")
    self.bitmap.blt(162,45,b_name,b_name.rect)
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
    self.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 顯示資訊
  #--------------------------------------------------------------------------
  def show_info
    @s_info.show_info
  end
  #--------------------------------------------------------------------------
  # ● 是否正在顯示bonus效果？
  #--------------------------------------------------------------------------
  def bonus_effect_now?
    @s_info.bonus_effect_now?
  end
end
end
