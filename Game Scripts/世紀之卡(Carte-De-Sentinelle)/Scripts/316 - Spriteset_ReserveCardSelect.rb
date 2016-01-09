#encoding:utf-8
#==============================================================================
# ■ Spriteset_ReserveCardSelect
#------------------------------------------------------------------------------
#     提供卡片保留輸入的精靈
#==============================================================================
module CardBattle
class Spriteset_ReserveCardSelect
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :input_handler
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport)
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
    @select_btn = Sprite_SelectReserveButton.new(@viewport)
    @select_btn.sensor_set_sense_input(method(:handler_card_ok))
    @banner_sprite = Sprite_SelectReserveBanner.new(@viewport)
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
      # 忙碌中的精靈不受控制
      # 不可用的卡無法被保留
      if sprite.mouse_in_area? && !sprite.effect?  && sprite.card_usable?
        sprite.to_selected_effect
        sprite_card = sprite.card_obj
        if Input.trigger?(:C)
          # 檢查該卡片的出牌狀態
          if @target_set.reserved_cards_flags[index] # 若已保留
            @target_set.reserved_cards_flags[index] = false
            move_sprite_to_unselect(sprite)
          else # 仍未出牌
            # 檢查剩餘容量
            if @target_set.reserve_size_enough?
              @target_set.reserved_cards_flags[index] = true
              move_sprite_to_select(sprite)
            end
          end
          # 列出保留卡
          @target_set.print_temp_reserved_cards
        end
        #puts "滑鼠位置：#{index}，內容#{sprite.card_obj.card_point}"
      else
        sprite.to_unselect_effect
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 將卡片精靈移動到出牌區
  #--------------------------------------------------------------------------
  def move_sprite_to_select(sprite)
    sprite.to_reserved_effect
  end
  #--------------------------------------------------------------------------
  # ● 將卡片精靈移動到後備區
  #--------------------------------------------------------------------------
  def move_sprite_to_unselect(sprite)
    sprite.to_unreserve_effect
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
    # 將保留牌旗標轉化為真正卡牌
    @target_set.parse_reserved_card
    # 其他精靈行為
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