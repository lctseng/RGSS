#encoding:utf-8
#==============================================================================
# ■  Lctseng::Spriteset_CardBuy
#------------------------------------------------------------------------------
#  卡片購買
#==============================================================================
module Lctseng
class Spriteset_CardBuy
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(master)
    @master = master
    create_sprites
    update_sprite
    refresh_total_number
    refresh_on_change_card
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    # 背景：固定
    @bg = Sprite.new
    @bg.bitmap = Cache.buy('buy_back')
    # 總金額
    @total = Sprite_Full.new
    @total.bitmap = Bitmap.new(150,20)
    @total.bitmap.font.bold = true
    @total.bitmap.font.size = 20
    @total.set_pos([379,22])
    # 剩餘金錢
    @remain = Sprite_Full.new
    @remain.bitmap = Bitmap.new(150,20)
    @remain.bitmap.font.bold = true
    @remain.bitmap.font.size = 20
    @remain.set_pos([379,39])
    # 按鈕群
    # 進入整備
    @prepare = Sprite_BuyActionButton.new([104,431],'action_prepare')
    # 換頁按鈕
    @page_btns = []
    @page_btns[0] = Sprite_PrepareActionButton.new([256,431],'action_next_page')
    @page_btns[1] = Sprite_PrepareActionButton.new(@page_btns[0].current_pos,'action_prev_page')
    @current_page_btn = @page_btns[CardBattle::card_page_index]
    # 確認購買
    @confirm = Sprite_BuyActionButton.new([413,431],'action_buy')
    # 卡牌頁
    @pages = []
    ## 第一頁
    p0 = @pages[0] = Spriteset_CardPageBuy.new(self)
    ## 攻擊標籤
    p0.add_tag do |s,opts|
      opts[:pos] = :up
      opts[:filename] = 'buy_sign_atk'
    end
    ## 防禦標籤
    p0.add_tag do |s,opts|
      opts[:pos] = :down
      opts[:filename] = 'buy_sign_def'
    end
    ## 攻擊卡
    [CardBattle::CardInfo::ATK_3,
        CardBattle::CardInfo::ATK_5,
        CardBattle::CardInfo::ATK_10,
        CardBattle::CardInfo::ATK_15,
        CardBattle::CardInfo::ATK_30]
    .each_with_index do |id,index|
       p0.add_card do |s,opts|
        opts[:id] = id
        opts[:pos] = {type: :up,max: 5,current: index + 1}
      end
    end
    ## 防禦卡
    [CardBattle::CardInfo::DEF_3,
        CardBattle::CardInfo::DEF_5,
        CardBattle::CardInfo::DEF_10,
        CardBattle::CardInfo::DEF_15,
        CardBattle::CardInfo::DEF_30]
    .each_with_index do |id,index|
       p0.add_card do |s,opts|
        opts[:id] = id
        opts[:pos] = {type: :down,max: 5,current: index + 1}
      end
    end      
    ## 第二頁
    p1 = @pages[1] = Spriteset_CardPageBuy.new(self)
    ## 特殊標籤
    p1.add_tag do |s,opts|
      opts[:pos] = :up
      opts[:filename] = 'buy_sign_sp'
    end
    ## 絕招標籤
    p1.add_tag do |s,opts|
      opts[:pos] = :down
      opts[:filename] = 'buy_sign_spatk'
    end
    ## 特殊卡
    [CardBattle::CardInfo::S_IN,
        CardBattle::CardInfo::S_RE,
        CardBattle::CardInfo::S_EX]
    .each_with_index do |id,index|
       p1.add_card do |s,opts|
        opts[:id] = id
        opts[:pos] = {type: :up,max: 3,current: index + 1}
      end
    end
    ## 絕招卡
    [CardBattle::CardInfo::U_SP,
        CardBattle::CardInfo::U_AT,
        CardBattle::CardInfo::U_MA,
        CardBattle::CardInfo::U_MR]
    .each_with_index do |id,index|
       p1.add_card do |s,opts|
        opts[:id] = id
        opts[:pos] = {type: :down,max: 4,current: index + 1}
      end
    end      
    
    
    ## 當前頁面
    @current_page = @pages[CardBattle::card_page_index]
    
    
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @pages.each {|s| s.dispose}
    @confirm.dispose
    @page_btns.each {|s| s.dispose}
    @prepare.dispose
    @remain.bitmap.dispose
    @remain.dispose
    @total.bitmap.dispose
    @total.dispose
    @bg.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_sprite
    update_input
  end
  #--------------------------------------------------------------------------
  # ● 更新精靈
  #--------------------------------------------------------------------------
  def update_sprite
    @prepare.update
    @confirm.update
    @pages.each do |s| 
      s.update
      s.visible =  @current_page == s
    end
    @page_btns.each do |s| 
      s.update
      s.visible =  @current_page_btn == s
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 更新輸入
  #--------------------------------------------------------------------------
  def update_input
    if Input.trigger?(:B)
      Sound.play_cancel
      @master.on_goto_prepare
    end
    if Input.trigger?(:C)
      @current_page.process_ok
      puts "已觸發確認鍵"
      if @prepare.on 
        Sound.play_ok
        @master.on_goto_prepare
      end
      # 下一頁偵測
      if @page_btns[0].on && @page_btns[0].visible
        change_index(1)
      end
      # 上一頁偵測
      if @page_btns[1].on && @page_btns[1].visible
        change_index(0)
      end
      if @confirm.on
        if $game_party.temp_gold != $game_party.gold
          RPG::SE.new('Coin').play
          on_buy_confirm
        else
          Sound.play_buzzer
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 取得角色
  #--------------------------------------------------------------------------
  def actor
    @master.actor
  end
  #--------------------------------------------------------------------------
  # ● 刷新總金額
  #--------------------------------------------------------------------------
  def refresh_total_number
    @total.bitmap.clear
    @total.draw_text(@total.bitmap.rect,$game_party.gold,2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新剩餘金額
  #--------------------------------------------------------------------------
  def refresh_remain_number
    @remain.bitmap.clear
    @remain.draw_text(@remain.bitmap.rect,$game_party.temp_gold,2)
  end
  #--------------------------------------------------------------------------
  # ● 箭頭點選後
  #--------------------------------------------------------------------------
  def on_arrow_click
    RPG::SE.new('Cursor1').play
    refresh_on_change_card

  end
  #--------------------------------------------------------------------------
  # ● 當卡片數量有任何更換時的刷新
  #--------------------------------------------------------------------------
  def refresh_on_change_card
    refresh_remain_number
    @pages.each do |page|
      page.refresh_arrow_enabled
    end
  end
  #--------------------------------------------------------------------------
  # ● 改變顯示的卡片頁
  #--------------------------------------------------------------------------
  def change_index(index)
    CardBattle::card_page_index = index
    @current_page = @pages[CardBattle::card_page_index]
    @current_page_btn = @page_btns[CardBattle::card_page_index]
    RPG::SE.new("Cursor1").play
  end
  #--------------------------------------------------------------------------
  # ● 確認購買
  #--------------------------------------------------------------------------
  def on_buy_confirm
    $game_party.confirm_buy
    refresh_total_number
    refresh_remain_number
    @pages.each do |page|
      page.refresh_all
    end
  end
end
end
