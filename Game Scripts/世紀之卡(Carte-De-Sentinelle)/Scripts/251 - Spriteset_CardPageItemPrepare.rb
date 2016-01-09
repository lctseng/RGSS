#encoding:utf-8
#==============================================================================
# ■ Spriteset_CardPageItemPrepare
#------------------------------------------------------------------------------
#  卡牌頁內的卡牌精靈：整備
#==============================================================================
module Lctseng
class Spriteset_CardPageItemPrepare < Spriteset_CardPageItem
  #--------------------------------------------------------------------------
  # ● 重繪數字
  #--------------------------------------------------------------------------
  def redraw_number
    return if @id <= 0
    @num_draw.bitmap.clear
    if actor.card_usable?(@id)
      current = actor.real_card_hash[@id]
      store = actor.store_card_hash[@id]
      max = current + store
      # 繪製左邊
      ## 設定顏色
      if current == 0 # 紅色
        color = @num_draw.text_color(2)
      elsif current == max # 黃色
        color = @num_draw.text_color(6)
      else
        color = @num_draw.text_color(3) # 綠色
      end
      rect = @num_draw.bitmap.rect.clone
      rect.width /= 2
      rect.width -= 6
      @num_draw.change_color(color)
      @num_draw.draw_text(rect,current,2)
      # 繪製右邊
      @num_draw.change_color(@num_draw.normal_color)
      @num_draw.draw_text(@num_draw.bitmap.rect,sprintf('/ %2d',max),2)
    else
      @num_draw.change_color(@num_draw.text_color(2))
      @num_draw.draw_text(@num_draw.bitmap.rect,"無法使用",1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否可點上？
  #--------------------------------------------------------------------------
  def arrow_up_ok?
    # ID檢查
    return false if @id <= 0 
    # 檢查是否可使用
    return false if !actor.card_usable?(@id)
    # 檢查是否還有庫存
    return false if actor.store_card_hash[@id] <= 0
    # 檢查卡片最大上限
    return false if actor.card_number >= CardBattle::MAX_CARD_NUMBER
    return true
  end
  #--------------------------------------------------------------------------
  # ● 是否可點下？
  #--------------------------------------------------------------------------
  def arrow_down_ok?
    # ID檢查
    return false if @id <= 0 
    # 檢查是不是還可以扣
    return false if actor.real_card_hash[@id] <= 0
    # 檢查卡片最小下限
    return false if actor.card_number <= CardBattle::MIN_CARD_NUMBER
    return true
  end
  #--------------------------------------------------------------------------
  # ● 點上
  #--------------------------------------------------------------------------
  def on_arrow_up
    
    # 增加一張到實際卡牌庫
    actor.real_card_hash[@id] += 1
    # 庫存減一張
    actor.store_card_hash[@id] -= 1
    puts "庫存剩餘#{actor.store_card_hash[@id]}"
    post_change_card
    @up.refresh_enable_state
    super
  end
  #--------------------------------------------------------------------------
  # ● 點下
  #--------------------------------------------------------------------------
  def on_arrow_down
    
    # 增加一張到庫存
    actor.store_card_hash[@id] += 1
    # 出戰減一張
    actor.real_card_hash[@id] -= 1
    puts "庫存剩餘#{actor.store_card_hash[@id]}"
    post_change_card
    @down.refresh_enable_state
    super
  end
  #--------------------------------------------------------------------------
  # ● 卡片數量更換後的處理
  #--------------------------------------------------------------------------
  def post_change_card
    actor.refresh_card_hash
    redraw_number
  end
end
end