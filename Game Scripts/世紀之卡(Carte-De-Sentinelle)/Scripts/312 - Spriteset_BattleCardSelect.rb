#encoding:utf-8
#==============================================================================
# ■ Spriteset_BattleCardSelect
#------------------------------------------------------------------------------
#     提供卡片選擇輸入的精靈
#==============================================================================
module CardBattle
class Spriteset_BattleCardSelect
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :input_handler
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(main_spriteset,viewport)
    @main_spriteset = main_spriteset
    @viewport = viewport
    create_sprites
    @input_mode_handler = nil
    @input_start = false
    @target_set_spriteset = nil
    @target_cards = []
    @ending = false
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    @select_btn = Sprite_SelectCardButton.new(@viewport)
    @select_btn.sensor_set_sense_input(method(:handler_card_ok))
    @banner_sprite = Sprite_SelectCardBanner.new(@viewport)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @select_btn.dispose
    @banner_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    @select_btn.update
    @banner_sprite.update
    update_check_card_select if !@ending
  end
  #--------------------------------------------------------------------------
  # ● 更新卡片選擇
  #--------------------------------------------------------------------------
  def update_check_card_select
    #puts "更新卡片.."
    @target_cards.each_with_index do |sprite,index|
      if sprite.mouse_in_area? && !sprite.effect? # 忙碌中的精靈不受控制
        sprite.to_selected_effect
        card = sprite.card_obj
        if Input.trigger?(:C)
          if card && card.card_type == :special
            if sprite.card_usable? 
              sprite.mark_card_used
              sprite.fader_set_fade(50,BATTLE_CARD_USE_FADE_TIME)
              case card.card_effect
              when :deliver
                prepare_redraw_for_player
              when :interrupt
                prepare_redraw_for_enemy
              when :exchange
                prepare_exchange_card_table
              end
            else
              
            end


          else # 正常牌處理
            # 檢查該卡片的出牌狀態
            if @target_set.card_select_state(index) # 若已出牌
              @target_set.unselect_card_by_index(index)
              move_sprite_to_unselect(sprite)
            else # 仍未出牌
              if @target_set.card_usable?(card) 
                @target_set.select_card_by_index(index)
                move_sprite_to_select(sprite)
              end

            end
            # 列出暫時出擊卡
            @target_set.print_temp_selected_cards
          end
        end
        #puts "滑鼠位置：#{index}，內容#{sprite.card_obj.card_point}"
      else
        sprite.to_unselect_effect
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 準備交換桌面卡牌
  #--------------------------------------------------------------------------
  def prepare_exchange_card_table
     puts "要求牌組交換"
    # 設置交換的處理精靈
    @select_btn.fader_set_post_handler(method(:handler_card_exchange))
    # 重抽前準備
    redraw_prepare
    # 要求總精靈把指定卡組的卡片精靈移動到交換離開區
    @main_spriteset.card_table_exchange_clear
  end
  #--------------------------------------------------------------------------
  # ● 重抽準備
  #--------------------------------------------------------------------------
  def redraw_prepare
    # 停止出牌鈕的偵測
    @select_btn.sensor_deactivate
    # 設定所有圖片淡出
    @select_btn.fader_set_fade(0,BATTLE_REDRAW_BUTTON_FADE_TIME)
    @banner_sprite.fader_set_fade(0,BATTLE_REDRAW_BUTTON_FADE_TIME)
    # 設定結束標記
    @ending = true

  end
  #--------------------------------------------------------------------------
  # ● 玩家準備重抽
  #   將按鈕以及圖片淡出
  #--------------------------------------------------------------------------
  def prepare_redraw_for_player
    puts "要求替玩家重抽卡片"
    # 設置重抽的處理精靈
    @select_btn.fader_set_post_handler(method(:handler_player_card_redraw))
    # 重抽前準備
    redraw_prepare
    # 要求總精靈把指定卡組的卡片精靈移動到離開區
    @main_spriteset.player_card_redraw_clear
  end
  #--------------------------------------------------------------------------
  # ● 敵人準備重抽
  #   將按鈕以及圖片淡出
  #--------------------------------------------------------------------------
  def prepare_redraw_for_enemy
    puts "要求替敵人重抽卡片"
    # 設置重抽的處理精靈
    @select_btn.fader_set_post_handler(method(:handler_enemy_card_redraw))
    # 重抽前準備
    redraw_prepare
    # 要求總精靈把指定卡組的卡片精靈移動到離開區
    @main_spriteset.enemy_card_redraw_clear
  end
  #--------------------------------------------------------------------------
  # ● 交換 - 圖片已消失，交換啟動
  #--------------------------------------------------------------------------
  def handler_card_exchange
    @input_start = false
    @main_spriteset.start_exchange
  end
  #--------------------------------------------------------------------------
  # ● 玩家重抽 - 圖片已消失，重抽啟動
  #--------------------------------------------------------------------------
  def handler_player_card_redraw
    @input_start = false
    @main_spriteset.start_redraw_for_player
  end
  #--------------------------------------------------------------------------
  # ● 敵人重抽 - 圖片已消失，重抽啟動
  #--------------------------------------------------------------------------
  def handler_enemy_card_redraw
    @input_start = false
    @main_spriteset.start_redraw_for_enemy
  end
  #--------------------------------------------------------------------------
  # ● 將卡片精靈移動到出牌區
  #--------------------------------------------------------------------------
  def move_sprite_to_select(sprite)
    from = sprite.current_pos
    to = CardBattle.player_selected_pos(sprite.index)
    sprite.slider_set_move(from,to,BATTLE_SELECT_CARD_SLIDE_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 將卡片精靈移動到後備區
  #--------------------------------------------------------------------------
  def move_sprite_to_unselect(sprite)
    from = sprite.current_pos
    to = CardBattle.player_prepare_pos(sprite.index)
    sprite.slider_set_move(from,to,BATTLE_SELECT_CARD_SLIDE_TIME)
  end
  
  
  #--------------------------------------------------------------------------
  # ● 開始輸入 (由外部呼叫)
  #--------------------------------------------------------------------------
  def start_input(target_set_spriteset)
    @target_set_spriteset = target_set_spriteset
    @target_set = @target_set_spriteset.card_set
    @target_cards = @target_set_spriteset.get_card_sprites
    @input_start = true
    @ending = false
    @select_btn.sensor_activate
    @select_btn.fader_clear_handler
    @select_btn.fader_set_fade(255,BATTLE_BUTTON_FADE_TIME)
    @banner_sprite.fader_set_fade(150,BATTLE_BUTTON_FADE_TIME)
  end
  #--------------------------------------------------------------------------
  # ● 確認出牌偵測 ， 由按鈕精靈呼叫
  #--------------------------------------------------------------------------
  def handler_card_ok
    @select_btn.sensor_deactivate
    @select_btn.fader_set_post_handler(method(:handler_card_select_finish))
    @select_btn.fader_set_fade(0,BATTLE_BUTTON_FADE_TIME)
    @banner_sprite.fader_set_fade(0,BATTLE_BUTTON_FADE_TIME)
    @ending = true
  end
  #--------------------------------------------------------------------------
  # ● 最後出牌處理結束handler， 由按鈕精靈呼叫
  #--------------------------------------------------------------------------
  def handler_card_select_finish
    @input_start = false
    @input_handler.call
  end
  #--------------------------------------------------------------------------
  # ● 是否輸入中？
  #--------------------------------------------------------------------------
  def input?
    @input_start
  end
end
end