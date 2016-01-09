#encoding:utf-8
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解釋器。
#   本類在 Game_Map、Game_Troop、Game_Event 類的內部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 戰鬥準備
  #--------------------------------------------------------------------------
  def battle_prepare
    $game_system.scene_rollback = 1
    @need_rooback = 1
    puts "已設置index倒退"
    # 選角色
    proc = Proc.new do
      puts "強制清除index倒退"
      clear_scene_rollback
    end
    Lctseng::Scene_SelectActor::set_clear_rollback(proc)
    Lctseng::Scene_SelectActor::clear_bgm_set
    SceneManager.scene.stand_terminate(false)
    SceneManager.call(Lctseng::Scene_SelectActor)
    
    Fiber.yield
  end
end
