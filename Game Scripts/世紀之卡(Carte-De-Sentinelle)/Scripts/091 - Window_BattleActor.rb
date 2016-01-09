#encoding:utf-8
#==============================================================================
# ■ Window_BattleActor
#------------------------------------------------------------------------------
# 　戰斗畫面中，選擇“隊友目標”的窗口。
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #     info_viewport : 信息顯示用顯示端口
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super()
    self.y = info_viewport.rect.y
    self.visible = false
    self.openness = 255
    @info_viewport = info_viewport
  end
  #--------------------------------------------------------------------------
  # ● 顯示窗口
  #--------------------------------------------------------------------------
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.x = width_remain
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 隱藏窗口
  #--------------------------------------------------------------------------
  def hide
    @info_viewport.rect.width = Graphics.width if @info_viewport
    super
  end
end
