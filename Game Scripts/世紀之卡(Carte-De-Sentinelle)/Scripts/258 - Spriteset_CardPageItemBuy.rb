#encoding:utf-8
#==============================================================================
# ■ Spriteset_CardPageItemBuy
#------------------------------------------------------------------------------
#  卡牌頁內的卡牌精靈：購買
#==============================================================================
module Lctseng
class Spriteset_CardPageItemBuy < Spriteset_CardPageItem
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites(opts)
    super
    # 金額欄位
    @price = Sprite_Full.new(@viewport)
    @price.bitmap = Bitmap.new(40,20)
    @price.bitmap.font.bold = true
    @price.bitmap.font.size = 18
    @price.center_origin
    @price.x = @card.x
    @price.y = @card.y + 65
    @price.draw_text(@price.bitmap.rect,"$#{@card_obj.price}",1)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @price.bitmap.dispose
    @price.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 重繪數字 (購買後 / 購買前)
  #--------------------------------------------------------------------------
  def redraw_number
    return if @id <= 0
    @num_draw.bitmap.clear
    buy = $game_party.temp_card_hash[@id]
    have = actor.card_hash[@id] + actor.store_card_hash[@id]
    current = buy + have
    # 繪製左邊
    ## 設定顏色
    if buy == 0 # 沒買，黃色
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
    @num_draw.draw_text(@num_draw.bitmap.rect,sprintf('/ %2d',have),2)
  end
  #--------------------------------------------------------------------------
  # ● 是否可點上？
  #--------------------------------------------------------------------------
  def arrow_up_ok?
    # ID檢查
    return false if @id <= 0 
    # 檢查是否錢夠
    return false if $game_party.temp_gold < @card_obj.price
    return true
  end
  #--------------------------------------------------------------------------
  # ● 是否可點下？
  #--------------------------------------------------------------------------
  def arrow_down_ok?
    # ID檢查
    return false if @id <= 0 
    # 檢查是不是還可以扣
    return false if $game_party.temp_card_hash[@id] <= 0
    return true
  end
  
  #--------------------------------------------------------------------------
  # ● 點上
  #--------------------------------------------------------------------------
  def on_arrow_up
    # 金錢減少
    $game_party.temp_gold -= @card_obj.price
    # 增加一張到暫時卡牌庫
    $game_party.temp_card_hash[@id] += 1
    post_change_card
    @up.refresh_enable_state
    super
  end
  #--------------------------------------------------------------------------
  # ● 點下
  #--------------------------------------------------------------------------
  def on_arrow_down
    # 金錢增加
    $game_party.temp_gold += @card_obj.price
    # 減少一張到暫時卡牌庫
    $game_party.temp_card_hash[@id] -= 1
    post_change_card
    @down.refresh_enable_state
    super
  end
  #--------------------------------------------------------------------------
  # ● 卡片數量更換後的處理
  #--------------------------------------------------------------------------
  def post_change_card
    redraw_number
  end
  #--------------------------------------------------------------------------
  # ● 數字輸入欄位墊高
  #--------------------------------------------------------------------------
  def number_box_pad
    super + 20
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 刷新持有數
    redraw_number
  end
end
end