#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_BattleReplenish
#------------------------------------------------------------------------------
#      顯示補充的精靈
#==============================================================================
module CardBattle
class Spriteset_BattleReplenish
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
    create_sprites
    clear_effect
    register_proc
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    # 背景
    @bg = Sprite_Full.new(@viewport)
    @bg.bitmap = Cache.battle('card_replenish_bg')
    @bg.fader_init
    # 橫條
    @bar = Sprite_Full.new(@viewport)
    @bar.bitmap = Cache.battle('card_replenish_bar')
    @bar.fader_init
    @bar.slider_init
    # 文字
    @word = Sprite_Full.new(@viewport)
    @word.bitmap = Cache.battle('card_replenish_word')
    @word.fader_init
    @word.slider_init
  end
  #--------------------------------------------------------------------------
  # ● 清除特效
  #--------------------------------------------------------------------------
  def clear_effect
    # 背景
    @bg.opacity = 0
    # 橫條
    @bar.opacity = 0
    @bar.center_origin
    @bar.set_pos [0,Graphics.height / 2]
    # 文字
    @word.opacity = 0
    @word.center_origin
    @word.set_pos [Graphics.width,Graphics.height / 2]
  end
  #--------------------------------------------------------------------------
  # ● 註冊操作
  #--------------------------------------------------------------------------
  def register_proc
    # 顯示
    @action_hash[0] = Proc.new do
      RPG::SE.new('Powerup').play
      
      @bg.fader_set_fade(255,10)
      # 
      @bar.fader_set_fade(255,10)
      @bar.slider_set_move(@bar.current_pos,[Graphics.width / 2,Graphics.height / 2],30)
      # 
      @word.fader_set_fade(255,10)
      @word.slider_set_move(@word.current_pos,[Graphics.width / 2,Graphics.height / 2],30)
    end
    # 消除
    @action_hash[75] = Proc.new do
      @bg.fader_set_fade(0,15)
      #
      @bar.fader_set_fade(0,15)
      @bar.slider_set_move(@bar.current_pos,[Graphics.width,Graphics.height / 2],30)
      #
      @word.fader_set_fade(0,15)
      @word.slider_set_move(@bar.current_pos,[0,Graphics.height / 2],30)
    end
    # 結束
    @action_hash[91] = Proc.new do
      @action_start = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @word.dispose
    @bar.dispose
    @bg.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    if @action_start
      @bg.fader_update
      @bar.fader_update
      @bar.slider_update
      @word.fader_update
      @word.slider_update
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
  def show
    puts  "顯示卡牌補充提示"
    # 重置特效
    clear_effect
    # 重置程序
    @action_start = true
    @action_counter = 0
  end  
end
end