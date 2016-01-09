#encoding:utf-8
#==============================================================================
# ■ Spriteset_CardPageItem
#------------------------------------------------------------------------------
#  卡牌頁內的卡牌精靈
#==============================================================================
module Lctseng
class Spriteset_CardPageItem
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(master,viewport)
    @viewport = viewport
    @master = master
    @id = 0
    @card_obj = nil
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites(opts)
     @id = opts[:id]
     @card_obj = CardBattle::CardInfo.card_info(@id)
    # 圖片精靈
    @card = Sprite.new(@viewport)
    ## 圖片
    fname = CardBattle::CardInfo.card_id_to_name(@id)
    @card.bitmap = bitmap_loader.call(fname)
    @card.center_origin
    ## 位置
    @card.set_pos(calculate_pos(opts[:pos]))
    # 數字欄位
    @num_base = Sprite.new(@viewport)
    @num_base.bitmap = bitmap_loader.call('numbox')
    @num_base.center_origin
    @num_base.x = @card.x
    @num_base.y = @card.y + number_box_pad
    # 繪製欄位
    @num_draw = Sprite_Full.new(@viewport)
    @num_draw.bitmap = Bitmap.new(@num_base.bitmap.rect.width - 10,@num_base.bitmap.rect.height)
    @num_draw.bitmap.font.bold = true
    @num_draw.center_origin
    @num_draw.set_pos(@num_base.current_pos)
    redraw_number
    # 按鈕：上
    @up = Sprite_PrepareActionArrow.new([@num_base.x + 40,@num_base.y - 14],'selec_btn_up',@viewport)
    @up.center_origin
    @up.z = @num_base.z + 100
    @up.check_handler = method(:arrow_up_ok?)
    # 按鈕：下
    @down = Sprite_PrepareActionArrow.new([@num_base.x + 40,@num_base.y + 14],'selec_btn_down',@viewport)
    @down.center_origin
    @down.z = @num_base.z + 100
    @down.check_handler = method(:arrow_down_ok?)

  end
  #--------------------------------------------------------------------------
  # ● 計算位置
  #--------------------------------------------------------------------------
  def calculate_pos(info)
    x = 0
    y = 0
    # Y 座標
    case info[:type]
    when :up
      y = 131
    when :down
      y = 280
    end
    # X 座標
    ix = 105
    cx = 340
    sx = 0
    # 奇數
    if info[:max].odd?
      mid = (info[:max] / 2) + 1
    else
      mid = ((info[:max] +1 ) / 2.0) 
    end
    sx = (info[:current] - mid) * ix
    x = cx + sx
    return [x,y]
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @down.dispose
    @up.dispose
    @num_draw.bitmap.dispose
    @num_draw.dispose
    @num_base.dispose
    @card.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    @up.update
    @down.update
  end
  #--------------------------------------------------------------------------
  # ● 數字輸入欄位墊高
  #--------------------------------------------------------------------------
  def number_box_pad
    65
  end
  #--------------------------------------------------------------------------
  # ● 讀取Bitmap
  #--------------------------------------------------------------------------
  def bitmap_loader
    @master.bitmap_loader
  end
  #--------------------------------------------------------------------------
  # ● 重繪數字
  #--------------------------------------------------------------------------
  def redraw_number
    
  end
  #--------------------------------------------------------------------------
  # ● 取得角色
  #--------------------------------------------------------------------------
  def actor
    @master.actor
  end
  #--------------------------------------------------------------------------
  # ● 觸發確認鍵
  #--------------------------------------------------------------------------
  def process_ok
    if @up.on
      on_arrow_up
    elsif @down.on
      on_arrow_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否可點上？
  #--------------------------------------------------------------------------
  def arrow_up_ok?
    true
  end
  #--------------------------------------------------------------------------
  # ● 是否可點下？
  #--------------------------------------------------------------------------
  def arrow_down_ok?
    true
  end
  #--------------------------------------------------------------------------
  # ● 點上
  #--------------------------------------------------------------------------
  def on_arrow_up
    @master.on_arrow_click
  end
  #--------------------------------------------------------------------------
  # ● 點下
  #--------------------------------------------------------------------------
  def on_arrow_down
    @master.on_arrow_click
  end
  #--------------------------------------------------------------------------
  # ● 刷新箭頭是否可以按
  #--------------------------------------------------------------------------
  def refresh_arrow_enabled
    # 上
    @up.opacity = arrow_up_ok? ? 255 : 160
    # 下
    @down.opacity = arrow_down_ok? ? 255 : 160
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    
  end
end
end