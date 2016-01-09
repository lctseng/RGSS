#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_EnemyBattleCards
#------------------------------------------------------------------------------
#    管理敵人方卡片
#==============================================================================
module CardBattle
class Spriteset_EnemyBattleCards < Spriteset_BattleCards
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(main_spriteset,viewport)
    super
  end
  #--------------------------------------------------------------------------
  # ● 鎖定所屬的卡組對象
  #--------------------------------------------------------------------------
  def set_card_set
    @card_set = CardBattleManager.e_cards
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # ● 卡片預備位置 ( 抽象方法 )
  #--------------------------------------------------------------------------
  def card_prepare_pos(index)
    CardBattle.enemy_prepare_pos(index)
  end
  
  #--------------------------------------------------------------------------
  # ● 回到發卡前的準備區
  #--------------------------------------------------------------------------
  def sprite_back_to_deliver_pos
    # 重置發牌前位置，但保留卡不動
    @cards.each do |sprite|
      next if sprite.reserved_card
      sprite.x = -100
      sprite.y = 50
    end
  end

  #--------------------------------------------------------------------------
  # ● 設置發牌效果 
  #--------------------------------------------------------------------------
  def set_deliver_effect(card_sprite)
    super
    from = [-100,50]
    to = card_prepare_pos(card_sprite.index)
    card_sprite.slider_set_move(from,to,BATTLE_ENEMY_DELIVER_TIME)
    card_sprite.cover_card
  end
  #--------------------------------------------------------------------------
  # ● 自動戰鬥中，將已選的卡全部移動到出牌區 (抽象方法)
  #--------------------------------------------------------------------------
  def effect_move_to_ready
    index_flags = @card_set.selected_cards_flags
    puts "已選卡片旗標：#{index_flags.inspect}"
    @cards.each_with_index do |sprite,index|
      if(index_flags[index])
        # 如果此卡已在選擇flag之中，才將之送出到出牌區
        from = sprite.current_pos
        to = CardBattle.enemy_selected_pos(index)
        sprite.slider_set_move(from,to,BATTLE_AUTO_MOVE_TO_READY_TIME)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 重抽時的外部位置
  #--------------------------------------------------------------------------
  def redraw_outside_pos(sprite,from)
    [from[0],0 - sprite.height]
  end
  #--------------------------------------------------------------------------
  # ● 交換時時的離開位置
  #--------------------------------------------------------------------------
  def exchange_outside_pos(sprite,from)
    [from[0],350]
  end
  #--------------------------------------------------------------------------
  # ● 攤牌
  #--------------------------------------------------------------------------
  def show_card
    super
    index_flags = @card_set.selected_cards_flags
    @cards.each do |sprite|
      sprite.uncover_card_with_effect if  index_flags[sprite.index]
    end
    
  end
  
end
end