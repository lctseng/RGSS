#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　標題畫面
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    create_spriteset
    play_title_music
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈組
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Lctseng::Spriteset_Title.new
    @spriteset.wait_method = method(:wait_for_effect)
    @spriteset.command_method = method(:command_caller)
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_spriteset
  end

  #--------------------------------------------------------------------------
  # ● 釋放精靈組
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新 (基礎)
  #--------------------------------------------------------------------------
  def update_basic
    super
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # * 更新等待
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
    puts "更新等待"
  end
  #--------------------------------------------------------------------------
  # * 等待效果
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    while @spriteset.wait_effect?
      update_for_wait 
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令呼叫
  #--------------------------------------------------------------------------
  def command_caller(sym)
    case sym
    when :start
      command_new_game
    when :load
      command_continue
    when :credit
      command_credit
    when :exit
      command_shutdown
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“開始游戲”
  #--------------------------------------------------------------------------
  def command_new_game
    DataManager.setup_new_game
    time = 100
    RPG::BGS.fade(time)
    RPG::ME.fade(time)
    Graphics.fadeout(time * Graphics.frame_rate / 1000)
    RPG::BGS.stop
    RPG::ME.stop
    #SceneManager.goto(Scene_Map)
    if $TEST && Input.press?(:ALT)   # TODO：測試用
      #$game_variables[CardBattle::VARIABLE_ACTOR] = 2
      SceneManager.goto(Scene_Map)
      #SceneManager.goto Lctseng::Scene_CardPrepare 
    else
      SceneManager.goto(Lctseng::Scene_SelectStory)
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令“繼續游戲”
  #--------------------------------------------------------------------------
  def command_continue
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● 指令“製作名單”
  #--------------------------------------------------------------------------
  def command_credit
    SceneManager.call(Lctseng::Scene_Credit)
  end
  #--------------------------------------------------------------------------
  # ● 指令“退出游戲”
  #--------------------------------------------------------------------------
  def command_shutdown
    fadeout_all
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # ● 播放標題畫面音樂
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end

  

end
