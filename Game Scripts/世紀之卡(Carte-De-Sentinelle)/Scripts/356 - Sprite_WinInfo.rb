#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_WinInfo
#------------------------------------------------------------------------------
# 　顯示戰鬥勝利基底的精靈
#==============================================================================
module CardBattle
class Sprite_WinInfo < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(spriteset,frame,viewport = nil)
    super(viewport)
    @spriteset = spriteset
    @frame = frame
    self.z = @frame.z + 3
    @base_shift = - 50
    @bonus_info = {}
    @action_counter = 0
    @action_hash = {}
    @action_start = false
    @start_draw_bonus = false
    @bonus_draw_interval = 0
    create_bitmap
    register_action_proc
  end
  #--------------------------------------------------------------------------
  # ● 產生圖案
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(@frame.bitmap.width,@frame.bitmap.height)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
    self.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 繪製數字
  #--------------------------------------------------------------------------
  def draw_num(x,y,n,prefix = '')
    if n == 0
      draw_digit(x,y,n,green)
    else
      while n > 0
        d = n % 10
        n /= 10
        sx = draw_digit(x,y,d,prefix)
        x -= sx
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪製一位數
  #--------------------------------------------------------------------------
  def draw_digit(x,y,d,prefix)
    if !prefix.empty?
      b_map = Cache.win("#{prefix}_#{d}")
    else
      b_map = Cache.win("#{d}")
    end
    self.bitmap.blt(x,y,b_map,b_map.rect)
    return b_map.width
  end
  #--------------------------------------------------------------------------
  # ● 繪製資訊
  #--------------------------------------------------------------------------
  def draw_info
    # 說明文字
    draw_help
    # 原始數值
    draw_pre_value
    # 箭頭
    draw_arrows
    # 後來數值
    draw_post_value
    # 金錢
    draw_gold
  end
  #--------------------------------------------------------------------------
  # ● 繪製說明文字
  #--------------------------------------------------------------------------
  def draw_help
    b_map = Cache.win('Info')
    self.bitmap.blt(131 +@base_shift , 163,b_map,b_map.rect)
  end
  #--------------------------------------------------------------------------
  # ● 繪製原始數值
  #--------------------------------------------------------------------------
  def draw_pre_value
    dx = 248 + @base_shift
    dy = 166
    actor = $game_system.battle_result.pre_info
    3.times do |i|
      n = actor.params(i)
      draw_num(dx,dy,n)
      dy += 67
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪製箭頭群
  #--------------------------------------------------------------------------
  def draw_arrows
    3.times do |i|
      draw_arrow(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪製箭頭
  #--------------------------------------------------------------------------
  def draw_arrow(index,name = 'Arrow')
    dx = 275 + @base_shift
    dy = 163 + index * 67
    b_map = Cache.win(name)
    cr = b_map.rect.clone
    cr.x = dx
    cr.y = dy
    self.bitmap.clear_rect(cr)
    self.bitmap.blt(dx,dy,b_map,b_map.rect)
  end  
  #--------------------------------------------------------------------------
  # ● 繪製新的數值
  #--------------------------------------------------------------------------
  def draw_post_value
    dx = 357 + @base_shift
    dy = 164
    actor = $game_system.battle_result.post_info
    pre_actor = $game_system.battle_result.pre_info
    3.times do |i|
      n = actor.original_level_up_param(i)
      pre_n = pre_actor.params(i)
      draw_num(dx,dy,n,n > pre_n ? 'Green' : '')
      dy += 67
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪製金錢
  #--------------------------------------------------------------------------
  def draw_gold
    dx = 290 + @base_shift
    dy = 357
    n = $game_system.battle_result.gold
    draw_num(dx,dy,n,'Green')
  end

  #--------------------------------------------------------------------------
  # ● 顯示資訊
  #--------------------------------------------------------------------------
  def show_info
    self.x = @frame.x
    self.y = @frame.y
    setup_bonus
    draw_info
    start_animation_id(122)
    if bonus_effect_now?
      @action_start = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置獎勵
  #--------------------------------------------------------------------------
  def setup_bonus
    @bonus_info.clear
    actor = $game_system.battle_result.post_info
    3.times do |i|
      ori = actor.original_level_up_param(i)
      after = actor.param(i)
      if after > ori
        data = all = (ori..after).to_a
        if all.size > 60
          # 確保不會超過30個step
          cnt = all[0]
          final = all[-1]
          step = (  (final - cnt) / 2.0).ceil
          data = []
          while cnt  < final
            data.push cnt
            cnt += step
          end
          data.push final if data[-1] < final
        end
        @bonus_info[i] =  data
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否有bonus效果？
  #--------------------------------------------------------------------------
  def bonus_effect_now?
    !@bonus_info.empty?
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    if @action_start
      if @action_hash.has_key? @action_counter
        @action_hash[@action_counter].call
      end
      @action_counter += 1
    end
    if @start_draw_bonus
      if @bonus_draw_interval <= 0
        max_size = 0
        se = false
        dx = 357 + @base_shift
        3.times do |i|
          dy = 164 + i * 67
          data = @bonus_info[i]
          if data && !data.empty?
            max_size = [data.size,max_size].max
            self.bitmap.clear_rect( Rect.new(dx - 50,dy - 20,106,43) )
            n = data.shift
            # 可以畫
            RPG::SE.new("Ice1", 100,150).play if !se
            se = true
            draw_num(dx,dy,n,'Bonus')
          end
        end
        @bonus_draw_interval = (3 - max_size / 3 )
        @bonus_draw_interval = 0 if @bonus_draw_interval < 0
      else
        @bonus_draw_interval -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 註冊action
  #--------------------------------------------------------------------------
  def register_action_proc
    # 顯示大家的bonus!字樣 + Arrow
    @action_hash[30] = Proc.new do
      3.times do |i|
        # 確定有獎勵
        next if !@bonus_info.has_key?(i)
        # 顯示Bonus
        @spriteset.bonus[i].show
        # 畫箭頭
        if @bonus_info.has_key? i
          draw_arrow(i,'Arrow_Bonus')
        end
      end
    end
    # 隱藏Bonus文字 
    @action_hash[80] = Proc.new do
      3.times do |i|
        # 顯示Bonus
        @spriteset.bonus[i].hide
      end
    end
    # 數字
    @action_hash[90] = Proc.new do
      @start_draw_bonus = true
    end
    # 結束
    @action_hash[150] = Proc.new do
      @start_draw_bonus = false
      @action_start = false
      @bonus_info.clear
    end
  end
end
end
