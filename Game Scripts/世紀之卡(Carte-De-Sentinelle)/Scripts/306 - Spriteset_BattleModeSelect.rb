#encoding:utf-8
#==============================================================================
# ■ Spriteset_BattleModeSelect
#------------------------------------------------------------------------------
#     提供模式選擇輸入的精靈
#==============================================================================
module CardBattle
class Spriteset_BattleModeSelect
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :input_mode_handler
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    create_sprites
    @input_mode_handler = nil
    @input_start = false
    @selected_mode = nil
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    # 背景精靈
    @bg_sprite = Sprite_SelectModeBackground.new(@viewport)
    @bg_sprite.fader_set_post_handler(method(:post_bg_fade))
    # 白霧精靈
    @fog_sprite = Sprite_SelectModeFog.new(@viewport)
    @fog_sprite.fader_set_post_handler(method(:handler_post_fog_fade_in))
    # 確認精靈
    @confirm_sprite = Sprite_SelectModeConfirm.new(@viewport)
    @confirm_sprite.fader_set_post_handler(method(:handler_post_confirm_fade_in))
    # 攻擊精靈
    @atk_sprite = Sprite_SelectModeButton.new(:attack,@viewport)
    @atk_sprite.sensor_set_sense_input(method(:handler_mode_input))
    # 防禦精靈
    @def_sprite = Sprite_SelectModeButton.new(:defend,@viewport)
    @def_sprite.sensor_set_sense_input(method(:handler_mode_input))
    # 確認精靈
    @ok_sprite = Sprite_SelectModeButton.new(:ok,@viewport)
    @ok_sprite.sensor_set_sense_input(method(:handler_mode_confirm))
    # 取消精靈
    @cancel_sprite = Sprite_SelectModeButton.new(:cancel,@viewport)
    @cancel_sprite.sensor_set_sense_input(method(:handler_mode_confirm))
    init_handler
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇輸入方法
  #--------------------------------------------------------------------------
  def handler_mode_input(mode)
    puts "輸入模式：#{mode}"
    @selected_mode = mode
    # 關閉按鈕感應器
    @atk_sprite.sensor_deactivate
    @def_sprite.sensor_deactivate
    ##  處理按鈕消失
    # 重設消失後處理方法
    @atk_sprite.fader_clear_handler# fader_set_post_handler(method(:handler_post_fade_after_select))
    @def_sprite.fader_clear_handler
    # 按鈕消失
    @atk_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    @def_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    # 白霧淡入
    @fog_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_FOG_FADEIN_TIME)
    # 確認提示淡入
    @confirm_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_CONFIRM_FADEIN_TIME)
    # 背景淡出
    @bg_sprite.fader_clear_handler
    @bg_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BG_FADEOUT_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 初始化所有handler
  #--------------------------------------------------------------------------
  def init_handler
    # 背景精靈
    @bg_sprite.fader_set_post_handler(method(:post_bg_fade))
    # 白霧精靈
    @fog_sprite.fader_set_post_handler(method(:handler_post_fog_fade_in))
    # 確認精靈
    @confirm_sprite.fader_set_post_handler(method(:handler_post_confirm_fade_in))
    # 攻擊精靈
    @atk_sprite.sensor_set_sense_input(method(:handler_mode_input))
    # 防禦精靈
    @def_sprite.sensor_set_sense_input(method(:handler_mode_input))
    # 確認精靈
    @ok_sprite.sensor_set_sense_input(method(:handler_mode_confirm))
    # 取消精靈
    @cancel_sprite.sensor_set_sense_input(method(:handler_mode_confirm))
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇輸入淡出之後的處理
  #--------------------------------------------------------------------------
  def handler_post_fade_after_select
    puts "按鈕已消失，上個選項：#{@selected_mode}"
  end
  #--------------------------------------------------------------------------
  # ● 白霧淡入後處理 (已關閉)
  #--------------------------------------------------------------------------
  def handler_post_fog_fade_in
  end
  #--------------------------------------------------------------------------
  # ● 確認提示淡入後處理
  #--------------------------------------------------------------------------
  def handler_post_confirm_fade_in
    puts "確認提示已淡入"
    # 淡入按鈕
    @ok_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME)
    @cancel_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME)
    @ok_sprite.sensor_activate
    @cancel_sprite.sensor_activate
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇確認方法
  #--------------------------------------------------------------------------
  def handler_mode_confirm(mode)
    case mode
    when :ok
      on_ok_select
    when :cancel
      on_cancel_select
    end
  end
  #--------------------------------------------------------------------------
  # ● 確認選擇時
  #--------------------------------------------------------------------------
  def on_ok_select
    # 淡出確認按鈕，並清除處理程序
    @ok_sprite.fader_clear_handler
    @cancel_sprite.fader_clear_handler
    @ok_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    @cancel_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    # 關閉確認按鈕感應器
    @ok_sprite.sensor_deactivate
    @cancel_sprite.sensor_deactivate
    # 淡出白霧
    @fog_sprite.fader_clear_handler
    @fog_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_FOG_FADEOUT_TIME)
    # 淡出確認提示，更改handler來釋放控制權
    @confirm_sprite.fader_set_post_handler(method(:handler_post_ok))
    @confirm_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_CONFIRM_FADEOUT_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 確認完，清除畫面後，釋放控制權
  #--------------------------------------------------------------------------
  def handler_post_ok
    # 釋放更改的handler
    @confirm_sprite.fader_clear_handler
    # 關閉啟動標示
    @input_start = false
    # 將所選的模式傳回外層
    input_mode_handler.call(@selected_mode)
  end
  #--------------------------------------------------------------------------
  # ● 取消選擇時
  #--------------------------------------------------------------------------
  def on_cancel_select
    @selected_mode = nil
    # 淡出確認按鈕，並清除處理程序
    @ok_sprite.fader_clear_handler
    @cancel_sprite.fader_clear_handler
    @ok_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    @cancel_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME)
    # 關閉確認按鈕感應器
    @ok_sprite.sensor_deactivate
    @cancel_sprite.sensor_deactivate
    # 淡出白霧
    @fog_sprite.fader_clear_handler
    @fog_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_CANCEL_FOG_FADEOUT_TIME)
    # 淡出確認提示，更改handler來觸發一開始的狀態
    @confirm_sprite.fader_set_post_handler(method(:handler_post_cancel_clear))
    @confirm_sprite.fader_set_fade(0,BATTLE_MODE_SELECT_CONFIRM_FADEOUT_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 取消時重新選擇處理
  #--------------------------------------------------------------------------
  def handler_post_cancel_clear
    # 釋放更改的handler
    @confirm_sprite.fader_clear_handler
    # 初始化handler
    init_handler
    # 重新淡入選項選擇
    start_mode_input
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @bg_sprite.dispose
    @atk_sprite.dispose
    @def_sprite.dispose
    @fog_sprite.dispose
    @confirm_sprite.dispose
    @ok_sprite.dispose
    @cancel_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    @bg_sprite.update
    @atk_sprite.update
    @def_sprite.update
    @fog_sprite.update
    @confirm_sprite.update
    @ok_sprite.update
    @cancel_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 開始輸入 (由外部呼叫)
  #--------------------------------------------------------------------------
  def start_input
    @input_start = true
    # 初始化Handler
    init_handler
    # 開始執行輸入
    start_mode_input
  end
  #--------------------------------------------------------------------------
  # ● 開始輸入模式
  #--------------------------------------------------------------------------
  def start_mode_input
    puts "開始輸入模式.."
    
    # 淡入背景
    @bg_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_BG_FADEIN_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 背景淡入之後的處理
  #--------------------------------------------------------------------------
  def post_bg_fade
    puts "開始淡入選項"
    @atk_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME)
    @def_sprite.fader_set_fade(255,BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME)
    @atk_sprite.sensor_activate
    @def_sprite.sensor_activate
  end
  #--------------------------------------------------------------------------
  # ● 是否輸入中？
  #--------------------------------------------------------------------------
  def input?
    @input_start
  end
end
end