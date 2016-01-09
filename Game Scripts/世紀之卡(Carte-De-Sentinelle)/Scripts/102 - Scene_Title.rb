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
    SceneManager.clear
    Graphics.freeze
    create_background
    create_foreground
    create_command_window
    play_title_music
  end
  #--------------------------------------------------------------------------
  # ● 獲取漸變速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_background
    dispose_foreground
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new
    @sprite1.bitmap = Cache.title1($data_system.title1_name)
    @sprite2 = Sprite.new
    @sprite2.bitmap = Cache.title2($data_system.title2_name)
    center_sprite(@sprite1)
    center_sprite(@sprite2)
  end
  #--------------------------------------------------------------------------
  # ● 生成前景
  #--------------------------------------------------------------------------
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @foreground_sprite.z = 100
    draw_game_title if $data_system.opt_draw_title
  end
  #--------------------------------------------------------------------------
  # ● 繪制游戲標題
  #--------------------------------------------------------------------------
  def draw_game_title
    @foreground_sprite.bitmap.font.size = 48
    rect = Rect.new(0, 0, Graphics.width, Graphics.height / 2)
    @foreground_sprite.bitmap.draw_text(rect, $data_system.game_title, 1)
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景
  #--------------------------------------------------------------------------
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放前景
  #--------------------------------------------------------------------------
  def dispose_foreground
    @foreground_sprite.bitmap.dispose
    @foreground_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 執行精靈居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
  end
  #--------------------------------------------------------------------------
  # ● 關閉指令窗口
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 指令“開始游戲”
  #--------------------------------------------------------------------------
  def command_new_game
    DataManager.setup_new_game
    close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 指令“繼續游戲”
  #--------------------------------------------------------------------------
  def command_continue
    close_command_window
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● 指令“退出游戲”
  #--------------------------------------------------------------------------
  def command_shutdown
    close_command_window
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
