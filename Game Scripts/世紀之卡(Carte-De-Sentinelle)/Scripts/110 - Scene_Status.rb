#encoding:utf-8
#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　狀態畫面
#==============================================================================

class Scene_Status < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    @status_window = Window_Status.new(@actor)
    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● 切換角色
  #--------------------------------------------------------------------------
  def on_actor_change
    @status_window.actor = @actor
    @status_window.activate
  end
end
