#encoding:utf-8
#==============================================================================
# ■ CardBattle::Scene_BattleLose
#------------------------------------------------------------------------------
# 　戰鬥失敗場景
#==============================================================================

module CardBattle
class Scene_BattleLose < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    $game_system.battle_only = false
    RPG::BGM.stop
    RPG::ME.new('Gameover1').play
    @wait_time = LOSE_COVER_TIME
    @spriteset = Spriteset_BattleLose.new
    @fast = false
  end
  #--------------------------------------------------------------------------
  # ● 重新挑戰
  #--------------------------------------------------------------------------
  def process_try_again
    RPG::ME.stop
    Scene_CardBattle::set_load_record
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 回到標題
  #--------------------------------------------------------------------------
  def process_title
    RPG::ME.stop
    SceneManager.goto(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面(基礎)
  #--------------------------------------------------------------------------
  def update_basic
    super
    @spriteset.update
    update_add_cmd
    update_input
  end
  #--------------------------------------------------------------------------
  # ● 更新新增指令
  #--------------------------------------------------------------------------
  def update_add_cmd
    if @wait_time > 0 && !@fast # 還沒快轉才需要處理
      @wait_time -= 1
      if @wait_time == 120
        @spriteset.add_cmd
        @fast = false # 禁止快轉
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新指令輸入
  #--------------------------------------------------------------------------
  def update_input
    # 至少等待一段時間
    return if @wait_time > LOSE_LEAST_WAIT_TIME
    # 檢測快轉
    if !@fast
      if Input.trigger?(:C) || Input.trigger?(:B)
        puts "執行快轉"
        @fast = true
        @spriteset.fast_forward
      end
      
    end
    # 檢測指令點選
    if Input.trigger?(:C) 
      if @spriteset.in_again?
        Sound.play_ok
        process_try_again
      elsif @spriteset.in_title?
        Sound.play_ok
        process_title
      end
    end
  end

end
end
