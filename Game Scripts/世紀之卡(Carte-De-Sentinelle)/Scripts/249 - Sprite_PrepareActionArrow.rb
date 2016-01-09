#encoding:utf-8
#==============================================================================
# ■ Sprite_PrepareActionArrow
#------------------------------------------------------------------------------
#     整備指令的箭頭
#==============================================================================
module Lctseng
class Sprite_PrepareActionArrow < Sprite_PrepareActionButton
   #--------------------------------------------------------------------------
  # ● 滑鼠是否在精靈內？
  #--------------------------------------------------------------------------
  def sensor_mouse_in_area?
    if self.bitmap
      Mouse.area?(self.x - self.ox ,self.y - self.oy,self.width ,self.height )
    else
      false
    end
  end
end
end
