#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　顯示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless $@
    alias lctseng_for_pause_ex_at_Window_Message_for_Initialize initialize # 初始化對象
    alias lctseng_for_pause_ex_at_Window_Message_for_Dispose dispose # 釋放
    alias lctseng_for_pause_ex_at_Window_Message_for_Update update # 更新畫面
    alias lctseng_for_pause_ex_at_Window_Message_for_Update_placement update_placement # 更新窗口的位置
    #alias lctseng_for_pause_ex_at_Window_Message_for_
  end
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  def initialize(*args,&block)
    lctseng_for_pause_ex_at_Window_Message_for_Initialize(*args,&block)
    create_pause_sprite
  end
  #--------------------------------------------------------------------------
  # ● 釋放 - 重新定義
  #--------------------------------------------------------------------------
  def dispose(*args,&block)
    lctseng_for_pause_ex_at_Window_Message_for_Dispose(*args,&block)
    dispose_pause_sprite
  end
  #--------------------------------------------------------------------------
  # ● 建立暫停精靈
  #--------------------------------------------------------------------------
  def create_pause_sprite
    @pause_sprite = Lctseng::Sprite_MessagePause.new(self.viewport)
  end
  #--------------------------------------------------------------------------
  # ● 釋放暫停精靈
  #--------------------------------------------------------------------------
  def dispose_pause_sprite
    @pause_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 - 重新定義
  #--------------------------------------------------------------------------
  def update(*args,&block)
    lctseng_for_pause_ex_at_Window_Message_for_Update(*args,&block)
    update_pause_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新暫停精靈
  #--------------------------------------------------------------------------
  def update_pause_sprite
    @pause_sprite.update
    @pause_sprite.pause = self.pause
    @pause_sprite.y =self.y + 120
    @pause_sprite.z = self.z + 10
  end
end