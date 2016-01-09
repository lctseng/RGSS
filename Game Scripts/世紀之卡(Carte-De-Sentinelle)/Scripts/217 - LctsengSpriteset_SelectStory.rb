#encoding:utf-8
#==============================================================================
# ■ Lctseng::Spriteset_SelectStory
#------------------------------------------------------------------------------
#     處理選角色畫面精靈組
#==============================================================================
module Lctseng
class Spriteset_SelectStory
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● 等待用方法
  #--------------------------------------------------------------------------
  attr_accessor :command_method
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @index = 0
    create_viewports
    create_spritesets
    
  end
  #--------------------------------------------------------------------------
  # ● 產生顯示端口
  #--------------------------------------------------------------------------
  def create_viewports
    # 背景框架
    @viewport_base = Viewport.new
    # 資訊框架(Z = 10)
    @viewport_info = Viewport.new
    @viewport_info.z = 10
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈組
  #--------------------------------------------------------------------------
  def create_spritesets
    # 背景
    @base = Sprite.new(@viewport_base)
    @base.bitmap = Cache.picture("storyline_background")
    # 確認鍵
    @confirm = Sprite_StoryConfirm.new(@viewport_info)
    @confirm.z = 10
    # 指令
    @back = Sprite_SingleButton.new([417,428],'storyline_back',@viewport_info)
    # 角色組
    @actor = Spriteset_ActorStory.new(@index,@viewport_info)
    @actor.show
    # 上排按鈕組
    @btn = Spriteset_StoryButton.new(method(:set_index),@viewport_info)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    dispose_spritesets
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # ● 釋放精靈組
  #--------------------------------------------------------------------------
  def dispose_spritesets
    @confirm.dispose
    @btn.dispose
    @actor.dispose
    @back.dispose
    @base.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放顯示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport_base.dispose
    @viewport_info.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_spritesets
    update_input 
  end
  #--------------------------------------------------------------------------
  # ● 更新精靈組
  #--------------------------------------------------------------------------
  def update_spritesets
    @back.update
    @actor.update
    @btn.update
    @confirm.update
  end
  #--------------------------------------------------------------------------
  # ● 更新輸入
  #--------------------------------------------------------------------------
  def update_input
    if Input.trigger?(:B)
      Sound.play_cancel
      command_method.call(:back)
    end
    if Input.trigger?(:C)
      puts "已觸發確認鍵"
      if @confirm.on
        RPG::ME.new('Fanfare3').play
        process_select_ok
      elsif @back.on 
        if @back.check_command_availble
          @back.process_ok
          Sound.play_ok
          command_method.call(:back)
        else
          Sound.play_buzzer
        end
      end
      @btn.process_ok
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理選定完成
  #--------------------------------------------------------------------------
  def process_select_ok
    $game_variables[CardBattle::VARIABLE_STORY] = @index+1
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 等待效果
  #--------------------------------------------------------------------------
  def wait_for_effect
    if @wait_method
      @wait_method.call
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否需等待效果
  #--------------------------------------------------------------------------
  def wait_effect?
    false
  end
  #--------------------------------------------------------------------------
  # ● 設定index
  #--------------------------------------------------------------------------
  def set_index(index)
    @index = index
    @actor.refresh(@index)
    @confirm.show
  end
  
end
end