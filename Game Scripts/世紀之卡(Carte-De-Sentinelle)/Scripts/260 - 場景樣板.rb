#~ #encoding:utf-8
#~ #==============================================================================
#~ # ■ Lctseng::Scene_
#~ #------------------------------------------------------------------------------
#~ # 　畫面
#~ #==============================================================================

#~ module Lctseng
#~ class Scene_ < Scene_Base

#~   #--------------------------------------------------------------------------
#~   # ● 開始處理
#~   #--------------------------------------------------------------------------
#~   def start
#~     super
#~     create_spriteset
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 產生精靈組
#~   #--------------------------------------------------------------------------
#~   def create_spriteset
#~     @spriteset = 
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 結束處理
#~   #--------------------------------------------------------------------------
#~   def terminate
#~     super
#~     dispose_spriteset
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放精靈組
#~   #--------------------------------------------------------------------------
#~   def dispose_spriteset
#~     @spriteset.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新 (基礎)
#~   #--------------------------------------------------------------------------
#~   def update_basic
#~     super
#~     @spriteset.update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 指令呼叫
#~   #--------------------------------------------------------------------------
#~   def command_caller(id)
#~   end
#~   

#~ end
#~ end