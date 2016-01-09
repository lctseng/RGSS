#encoding:utf-8
#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　地圖畫面
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    $game_player.straighten
    $game_map.refresh
    $game_message.visible = false
    create_spriteset
    create_all_windows
    @menu_calling = false
  end
  #--------------------------------------------------------------------------
  # ● 執行進入場景時的漸變
  #--------------------------------------------------------------------------
  def perform_transition
    if Graphics.brightness == 0
      Graphics.transition(0)
      fadein(fadein_speed)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取漸變速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 15
  end
  #--------------------------------------------------------------------------
  # ● 結束前處理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle)
    pre_title_scene  if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_spriteset
    perform_battle_transition if SceneManager.scene_is?(Scene_Battle)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    $game_map.update(true)
    $game_player.update
    $game_timer.update
    @spriteset.update
    update_scene if scene_change_ok?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以切換場景
  #--------------------------------------------------------------------------
  def scene_change_ok?
    !$game_message.busy? && !$game_message.visible
  end
  #--------------------------------------------------------------------------
  # ● 更新場景消退時的過渡
  #--------------------------------------------------------------------------
  def update_scene
    check_gameover
    update_transfer_player unless scene_changing?
    update_encounter unless scene_changing?
    update_call_menu unless scene_changing?
    update_call_debug unless scene_changing?
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面（消退用）
  #--------------------------------------------------------------------------
  def update_for_fade
    update_basic
    $game_map.update(false)
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 通用的消退處理
  #--------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡入畫面
  #--------------------------------------------------------------------------
  def fadein(duration)
    fade_loop(duration) {|v| Graphics.brightness = v }
  end
  #--------------------------------------------------------------------------
  # ● 淡出畫面
  #--------------------------------------------------------------------------
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  #--------------------------------------------------------------------------
  # ● 淡入畫面（白）
  #--------------------------------------------------------------------------
  def white_fadein(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, 255 - v) }
  end
  #--------------------------------------------------------------------------
  # ● 淡出畫面（白）
  #--------------------------------------------------------------------------
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  #--------------------------------------------------------------------------
  # ● 生成精靈組
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 釋放精靈組
  #--------------------------------------------------------------------------
  def dispose_spriteset
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口
  #--------------------------------------------------------------------------
  def create_all_windows
    create_message_window
    create_scroll_text_window
    create_location_window
  end
  #--------------------------------------------------------------------------
  # ● 生成信息窗口
  #--------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_Message.new
  end
  #--------------------------------------------------------------------------
  # ● 生成滾動文字窗口
  #--------------------------------------------------------------------------
  def create_scroll_text_window
    @scroll_text_window = Window_ScrollText.new
  end
  #--------------------------------------------------------------------------
  # ● 生成地圖名稱窗口
  #--------------------------------------------------------------------------
  def create_location_window
    @map_name_window = Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # ● 監聽場所移動指令
  #--------------------------------------------------------------------------
  def update_transfer_player
    perform_transfer if $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● 監聽遇敵事件
  #--------------------------------------------------------------------------
  def update_encounter
    SceneManager.call(Scene_Battle) if $game_player.encounter
  end
  #--------------------------------------------------------------------------
  # ● 監聽取消鍵的按下。如果菜單可用且地圖上沒有事件在運行，則打開菜單界面。
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(:B)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  #--------------------------------------------------------------------------
  # ● 打開菜單畫面
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
  end
  #--------------------------------------------------------------------------
  # ● 監聽 F9 的按下。如果是游戲測試的情況下，則打開調試界面
  #--------------------------------------------------------------------------
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && Input.press?(:F9)
  end
  #--------------------------------------------------------------------------
  # ● 處理場所移動
  #--------------------------------------------------------------------------
  def perform_transfer
    pre_transfer
    $game_player.perform_transfer
    post_transfer
  end
  #--------------------------------------------------------------------------
  # ● 場所移動前的處理
  #--------------------------------------------------------------------------
  def pre_transfer
    @map_name_window.close
    case $game_temp.fade_type
    when 0
      fadeout(fadeout_speed)
    when 1
      white_fadeout(fadeout_speed)
    end
  end
  #--------------------------------------------------------------------------
  # ● 場所移動后的處理
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    @map_name_window.open
  end
  #--------------------------------------------------------------------------
  # ● 切換戰斗畫面前的處理
  #--------------------------------------------------------------------------
  def pre_battle_scene
    Graphics.update
    Graphics.freeze
    @spriteset.dispose_characters
    BattleManager.save_bgm_and_bgs
    BattleManager.play_battle_bgm
    Sound.play_battle_start
  end
  #--------------------------------------------------------------------------
  # ● 切換到標題畫面前的處理
  #--------------------------------------------------------------------------
  def pre_title_scene
    fadeout(fadeout_speed_to_title)
  end
  #--------------------------------------------------------------------------
  # ● 執行戰斗前的漸變
  #--------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, "Graphics/System/BattleStart", 100)
    Graphics.freeze
  end
  #--------------------------------------------------------------------------
  # ● 獲取淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 獲取淡入速度
  #--------------------------------------------------------------------------
  def fadein_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 獲取切換到標題畫面時的淡出速度
  #--------------------------------------------------------------------------
  def fadeout_speed_to_title
    return 60
  end
end
