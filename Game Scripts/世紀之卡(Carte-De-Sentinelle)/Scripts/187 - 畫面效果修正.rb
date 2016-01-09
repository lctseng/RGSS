#encoding:utf-8
#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　處理地圖畫面精靈和圖塊的類。本類在 Scene_Map 類的內部使用。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 更新顯示端口
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone.set($game_map.screen.tone)
    @viewport2.tone.set($game_map.screen.tone)
    @viewport2.ox = $game_map.screen.shake
    @viewport2.color.set($game_map.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end
