#encoding:utf-8
#==============================================================================
# ■ Lctseng::Spriteset_SelectActor
#------------------------------------------------------------------------------
#     處理選角色畫面精靈組
#==============================================================================
module Lctseng
class Spriteset_SelectActor
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
  def initialize(command_method)
    @command_method = command_method
    
    if CardBattle::actor_locked? || CardBattle::var_actor_id > 0
      @index = CardBattle.var_actor_index
    else
      @index = rand(2)
    end
    @actor_ids = [0]*2
    set_character
    create_viewports
    create_spritesets
    set_index(@index)
    
  end
  
  #--------------------------------------------------------------------------
  # ● 設置角色
  #--------------------------------------------------------------------------
  def set_character
    @actor_ids[0] = CardBattle.current_actor_id(0)
    @actor_ids[1] = @actor_ids[0] + 1
  end
  #--------------------------------------------------------------------------
  # ● 取得角色ID
  #--------------------------------------------------------------------------
  def actor_id
    @actor_ids[@index]
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
    @base.bitmap = Cache.picture("BattleSelectActor_Base")
    # 能力
    @point = Sprite_SelectActorFrame.new(@viewport_info)
    # 確認
    @confirm = Sprite_SelectActorConfirm.new(@viewport_info)
    @confirm.z = 100
    # 存檔
    @save = Sprite_SelectActorSave.new(@viewport_info)
    @save.z = @confirm.z
    # 立繪
    @actor = Lctseng::Sprite_ActorSelect.new(@viewport_base)
    @actor.z = 5
    # 按鈕
    @btn = Spriteset_ActorSelectButton.new(method(:set_index),@index,@viewport_info)
    # 整備按鈕
    @btn_prepare = Sprite_SingleButton.new([557,185,],'BattleSelect_Prepare')

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
    @btn_prepare.dispose
    @save.dispose
    @confirm.dispose
    @point.dispose
    @btn.dispose
    @actor.dispose
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
    @base.update
    @actor.update
    @btn.update
    @point.update
    @confirm.update
    @save.update
    @btn_prepare.update
  end
  #--------------------------------------------------------------------------
  # ● 更新輸入
  #--------------------------------------------------------------------------
  def update_input
    if Input.trigger?(:C)
      puts "已觸發確認鍵"
      @btn.process_ok
      if @confirm.on
        Sound.play_ok
        @confirm.process_ok
        @command_method.call(self.actor_id)
      end
      if @btn_prepare.on
        Sound.play_ok
        $game_variables[CardBattle::VARIABLE_ACTOR] = actor_id
        SceneManager.goto(Scene_CardPrepare)
      end
      if @save.on
        Sound.play_ok
        @save.process_ok
        @command_method.call(-1)
      end
    end
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
    puts "設定：#{index}"
    @index = index
    @actor.show(actor_id)
    @point.show(actor_id)
    @confirm.show
    @save.show
  end
  
end
end