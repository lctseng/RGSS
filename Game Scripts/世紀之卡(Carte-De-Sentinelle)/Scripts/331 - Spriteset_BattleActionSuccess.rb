#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_BattleActionSuccess
#------------------------------------------------------------------------------
#      顯示連續行動成功的精靈
#==============================================================================
module CardBattle
class Spriteset_BattleActionSuccess
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(master,viewport)
    @master = master
    @viewport = viewport
    @action_counter = 0
    @action_hash = {}
    @action_start = false
    @exp_name = ''
    create_sprites
    clear_effect
    register_proc
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    # 橫條
    @bar = Sprite_Full.new(@viewport)
    @bar.bitmap = Cache.battle('action_bonus_bar')
    @bar.fader_init
    @bar.slider_init
    # 文字
    @word = Sprite_Full.new(@viewport)
    @word.bitmap = Cache.battle('action_bonus_word')
    @word.fader_init
    @word.slider_init
    # 文字解說
    @explain = Sprite_Full.new(@viewport)
    @explain.fader_init
    @explain.slider_init
  end
  #--------------------------------------------------------------------------
  # ● 清除特效
  #--------------------------------------------------------------------------
  def clear_effect
    # 橫條
    @bar.opacity = 0
    @bar.center_origin
    @bar.set_pos [0,Graphics.height / 2]
    # 文字
    @word.opacity = 0
    @word.center_origin
    @word.set_pos [Graphics.width / 2,Graphics.height / 2 + 35]
    @word.z = 10
    # 解釋
    @explain.opacity = 0
    @explain.bitmap = Cache.battle(@exp_name)
    @explain.center_origin
    @explain.set_pos [Graphics.width,Graphics.height / 2 - 15 ]
    @explain.z = 20
  end
  #--------------------------------------------------------------------------
  # ● 註冊操作
  #--------------------------------------------------------------------------
  def register_proc
    # 顯示
    @action_hash[0] = Proc.new do
      # 
      @bar.fader_set_fade(255,10)
      @bar.slider_set_move(@bar.current_pos,[Graphics.width / 2,Graphics.height / 2],30)
      # 
      @explain.fader_set_fade(255,10)
      @explain.slider_set_move(@explain.current_pos,[Graphics.width / 2,@explain.y],30)
    end
    @action_hash[20] = Proc.new do
      RPG::SE.new('Skill2').play
      @word.flash(Color.new(255,255,255),30)
      @word.fader_set_fade(255,10)
    end
    # 消除
    @action_hash[75] = Proc.new do
      @bar.fader_set_fade(0,15)
      @bar.slider_set_move(@bar.current_pos,[Graphics.width,Graphics.height / 2],30)
      #
      @explain.fader_set_fade(0,15)
      @explain.slider_set_move(@explain.current_pos,[0,@explain.y],30)
      # 
      @word.fader_set_fade(0,15)
    end
    # 結束
    @action_hash[121] = Proc.new do
      @action_start = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @explain.dispose
    @word.dispose
    @bar.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    if @action_start
      @bar.fader_update
      @bar.slider_update
      @word.update
      @word.fader_update
      @word.slider_update
      @explain.fader_update
      @explain.slider_update
      if @action_hash.has_key? @action_counter
        @action_hash[@action_counter].call
      end
      @action_counter += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def effect?
    return true if @action_start
    return false
  end
  #--------------------------------------------------------------------------
  # ● 顯示
  #--------------------------------------------------------------------------
  def show(mode)
    puts  "顯示連續行動提示"
    # 設定檔案名稱
    if mode == :attack
      @exp_name = 'action_bonus_atk'
    else
      @exp_name = 'action_bonus_def'
    end
    # 重置特效
    clear_effect
    # 重置程序
    @action_start = true
    @action_counter = 0
  end  
end
end