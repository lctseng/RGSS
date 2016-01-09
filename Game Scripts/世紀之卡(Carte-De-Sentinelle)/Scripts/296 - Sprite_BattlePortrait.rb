#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_BattlePortrait
#------------------------------------------------------------------------------
# 　角色肖像中，顯示選擇模式的覆蓋精靈
#==============================================================================
module CardBattle
class Sprite_BattlePortrait < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(card_set,viewport)
    super(viewport)
    @card_set = card_set # 設定所屬卡組
    create_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 產生位圖
  #--------------------------------------------------------------------------
  def create_bitmap
    if @card_set.player?
      filename = "Player_#{@card_set.battler_id}"
    else
      filename = "Enemy_#{@card_set.battler_id}"
    end
    self.bitmap = Cache.battle("Portrait/#{filename}")
    if @card_set.player?
      self.oy = self.height
      self.z = 15
    else
      self.ox = self.width
      self.z = 5
    end
    set_pos(@card_set.portrait_sprite_pos)
  end

end
end
