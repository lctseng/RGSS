#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_BattleCards
#------------------------------------------------------------------------------
#      管理戰鬥中某一方的桌面上所有卡片的精靈
#==============================================================================
module CardBattle
class Spriteset_BattleCards
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :card_set

  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(main_spriteset,viewport)
    @main_spriteset = main_spriteset
    @viewport = viewport
    set_card_set
    create_sprites
  end
  #--------------------------------------------------------------------------
  # ● 鎖定所屬的卡組對象
  #--------------------------------------------------------------------------
  def set_card_set
    @card_set = nil
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    @cards = []
    6.times do |index|
      @cards.push(Sprite_BattleCard.new(self,index,@viewport))
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @cards.each do |sprite|
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    @cards.each do |sprite|
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def effect?
    @cards.any? do |sprite|
      sprite.effect?
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否動畫中？
  #--------------------------------------------------------------------------
  def animation?
    @cards.any? do |sprite|
      sprite.animation?
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除卡牌精靈內容
  #--------------------------------------------------------------------------
  def clear_card_sprite_data
    @cards.each do |sprite|
      sprite.clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置發牌效果 ( 抽象方法 )
  #--------------------------------------------------------------------------
  def set_deliver_effect(card_sprite)
    card_sprite.opacity = 255
  end
  #--------------------------------------------------------------------------
  # ● 自動戰鬥中，將已選的卡全部移動到出牌區 (抽象方法)
  #--------------------------------------------------------------------------
  def effect_move_to_ready
    
  end
  #--------------------------------------------------------------------------
  # ● 卡片預備位置 ( 抽象方法 )
  #--------------------------------------------------------------------------
  def card_prepare_pos(index)
    
  end
  #--------------------------------------------------------------------------
  # ● 將已出戰的精靈清除並丟回牌組位置
  #--------------------------------------------------------------------------
  def clear_selected_card
    @cards.each_with_index do |sprite,index|
      if @card_set.selected_cards_flags[index]
        sprite.fading_clear
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置發牌
  #--------------------------------------------------------------------------
  def set_deliver
    puts "設置發牌：#{self.class}"
    sprite_back_to_deliver_pos
    @card_set.recent_add_cards.each do |card|
      puts "新牌：#{card.inspect}"
      for card_sprite in @cards
        if !card_sprite.reserved_card && !card_sprite.card_obj
          card_sprite.set_card_object(card)
          set_deliver_effect(card_sprite)
          break
        end
      end
    end
    sync_card_index
  end
  #--------------------------------------------------------------------------
  # ● 檢視主陣列中，精靈的index狀態
  #--------------------------------------------------------------------------
  def show_index_status
    puts "檢視卡牌精靈index狀態"
    @cards.each_with_index do |sprite,index|
      card = sprite.card_obj
      puts "index：#{index}，卡片：#{card.inspect}"
    end
  end
  #--------------------------------------------------------------------------
  # ● 同步卡牌index
  # 用意：確保出牌時的index與精靈的index是同步的
  #--------------------------------------------------------------------------
  def sync_card_index
    puts "對象：#{self.class}"
    puts "執行卡牌index同步，執行前"
    @card_set.show_index_status
    self.show_index_status
    # 呼叫同步函數
    @card_set.sync_card_table_index_with_sprite(@cards)
    puts "執行卡牌index同步，執行後"
    @card_set.show_index_status
    self.show_index_status
    
  end
  #--------------------------------------------------------------------------
  # ● 設置保留牌
  #--------------------------------------------------------------------------
  def set_reserve
    ## 清除保留狀態
    @cards.each do |sprite|
      sprite.clear_reserve
      sprite.to_unreserve_effect
    end
    ## TODO：直接把被保留牌的移動到左方
    
    ## 找出保留的精靈
    reserved_sprite = []
    set_reserved_index = @card_set.reserved_index_list
    
    set_reserved_index.each do |r_index|
      @cards.each_with_index do |sprite,index|
        puts "精靈卡物件：#{sprite.card_obj.inspect}"
        if index == r_index && !sprite.reserved_card # 此精靈擁有保留卡
          sprite.set_reserve_current
          reserved_sprite.push(sprite)
          puts "已設定保留效果"
          break
        end
      end
    end
    
    puts "調整位置前卡牌精靈："
    @cards.each do |sprite|
      puts sprite.card_obj.inspect
    end
    
    reserved_sprite.sort!{|a,b| a.x - b.x }.each_with_index do |sprite,index|
      from = sprite.current_pos
      to = card_prepare_pos(index)
      sprite.set_post_reserve
      sprite.slider_set_move(from,to,BATTLE_RESERVE_SLIDE_TIME)
      #@cards.delete(sprite)
      #@cards.unshift(sprite)
    end
    
    @cards = reserved_sprite + (@cards - reserved_sprite)
    
    reset_sprite_index
    
    puts "調整位置後卡牌精靈："
    @cards.each do |sprite|
      puts sprite.card_obj.inspect
    end
    

    
    max_index = reserved_sprite.size
    for i in max_index...6
      @cards[i].fading_clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 重設精靈index
  #--------------------------------------------------------------------------
  def reset_sprite_index
    # 重設index
    @cards.each_with_index do |sprite,index|
      sprite.set_index(index)
    end

  end
  #--------------------------------------------------------------------------
  # ● 取得卡片精靈列表
  #--------------------------------------------------------------------------
  def get_card_sprites
    @cards
  end
  #--------------------------------------------------------------------------
  # ● 取得已出戰的卡片精靈列表
  #--------------------------------------------------------------------------
  def selected_card_sprites
    @cards.select do |sprite|
      @card_set.selected_cards_flags[sprite.index]
    end
  end
  #--------------------------------------------------------------------------
  # ● 回到發卡前的準備區 (抽象方法)
  #--------------------------------------------------------------------------
  def sprite_back_to_deliver_pos
  end
  #--------------------------------------------------------------------------
  # ● 重抽時的外部位置
  #--------------------------------------------------------------------------
  def redraw_outside_pos(sprite,from)
  end
  #--------------------------------------------------------------------------
  # ● 設置重抽，將精靈清除到視窗之外
  #--------------------------------------------------------------------------
  def redraw_clear_sprite_to_outside
    @cards.each do |sprite|
      from = sprite.current_pos
      to = redraw_outside_pos(sprite,from)
      duration = BATTLE_REDRAW_TIME_BASE + rand(BATTLE_REDRAW_TIME_RANDOM)
      sprite.slider_set_move(from,to,duration)
      sprite.fader_set_fade(0,duration)
    end
  end
  #--------------------------------------------------------------------------
  # ● 交換時時的離開位置
  #--------------------------------------------------------------------------
  def exchange_outside_pos(sprite,from)
  end
  #--------------------------------------------------------------------------
  # ● 設置交換，將精靈移動到交換區
  #--------------------------------------------------------------------------
  def sprite_clear_for_exchange
    @cards.each do |sprite|
      sprite.cover_card_with_effect
      from = sprite.current_pos
      to = exchange_outside_pos(sprite,from)
      duration = BATTLE_EXCHANGE_TIME_BASE + rand(BATTLE_EXCHANGE_TIME_RANDOM)
      sprite.slider_set_move(from,to,duration)
      sprite.fader_set_fade(0,duration)
    end
  end
  #--------------------------------------------------------------------------
  # ● 將桌面卡牌套用到精靈上
  #--------------------------------------------------------------------------
  def set_card_table_on_sprite
    puts "套用桌面卡牌到精靈：#{self.class}"
    # 清除原本的精靈資訊
    clear_card_sprite_data
    @card_set.current_card_table.each do |card|
      puts "新牌：#{card.inspect}"
      for card_sprite in @cards
        if !card_sprite.reserved_card && !card_sprite.card_obj
          card_sprite.set_card_object(card)
          set_exchange_effect(card_sprite)
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置交換效果 (從交換區回到原始位置)
  #--------------------------------------------------------------------------
  def set_exchange_effect(sprite)
    sprite.cover_card
    sprite.opacity = 0
    to = card_prepare_pos(sprite.index)
    from = sprite.current_pos
    #from = [to[0],sprite.current_pos[1]]
    duration = BATTLE_EXCHANGE_TIME
    sprite.slider_set_move(from,to,duration)
    if sprite.card_usable? || sprite.covered?
      sprite.fader_set_fade(255,duration)
    else
      sprite.fader_set_fade(50,duration)
    end
  end
  #--------------------------------------------------------------------------
  # ● 攤牌
  #--------------------------------------------------------------------------
  def show_card
    
  end



  
end
end