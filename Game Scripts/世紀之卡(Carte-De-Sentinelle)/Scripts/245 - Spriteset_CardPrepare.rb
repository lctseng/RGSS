#encoding:utf-8
#==============================================================================
# ■  Lctseng::Spriteset_CardPrepare
#------------------------------------------------------------------------------
#  卡片整備
#==============================================================================
module Lctseng
class Spriteset_CardPrepare
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(master)
    @master = master
    create_sprites
    update_sprite
    refresh_on_change_card
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprites
    # 背景：固定
    @bg = Sprite.new
    @bg.bitmap = Cache.prepare('selec_back')
    # 角色立繪：固定
    @actor = Sprite.new
    @actor.opacity = 100
    @actor.bitmap = Cache.picture("BattleSelectActor_Actor#{actor.id}")
    # 背景上框：固定
    @bg_frame = Sprite.new
    @bg_frame.bitmap = Cache.prepare('selec_backFrame')
    # 持有牌數說明
    @card_num_text = Sprite.new
    @card_num_text.bitmap = Cache.prepare('selec_back_cardnumber')
    @card_num_text.set_pos([341,21])
    # 角色名稱：固定
    @name = Sprite.new
    @name.bitmap = Cache.prepare("select_actor_#{actor.id}")
    @name.set_pos([100,23])
    # 角色總卡片數
    @total = Sprite_Full.new
    @total.bitmap = Bitmap.new(85,30)
    @total.bitmap.font.bold = true
    @total.set_pos([448,25])
    # 按鈕群
    # 進入購買
    @buy = Sprite_PrepareActionButton.new([104,431],'action_buy')
    # 回到選擇 (移除)
    #@actor_select = Sprite_PrepareActionButton.new([256,431,],'action_select')
    # 換頁按鈕
    @page_btns = []
    @page_btns[0] = Sprite_PrepareActionButton.new([256,431],'action_next_page')
    @page_btns[1] = Sprite_PrepareActionButton.new(@page_btns[0].current_pos,'action_prev_page')
    @current_page_btn = @page_btns[CardBattle::card_page_index]
    # 戰鬥
    @battle = Sprite_PrepareActionButton.new([413,431],'action_battle')
    # 卡牌頁
    @pages = []
    ## 第一頁
    p0 = @pages[0] = Spriteset_CardPagePrepare.new(self)
    ## 攻擊標籤
    p0.add_tag do |s,opts|
      opts[:pos] = :up
      opts[:filename] = 'selec_sign_atk'
    end
    ## 防禦標籤
    p0.add_tag do |s,opts|
      opts[:pos] = :down
      opts[:filename] = 'selec_sign_def'
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
    p1 = @pages[1] = Spriteset_CardPagePrepare.new(self)
    ## 特殊標籤
    p1.add_tag do |s,opts|
      opts[:pos] = :up
      opts[:filename] = 'selec_sign_sp'
    end
    ## 絕招標籤
    p1.add_tag do |s,opts|
      opts[:pos] = :down
      opts[:filename] = 'selec_sign_spatk'
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
    @battle.dispose
    @page_btns.each {|s| s.dispose}
    #@actor_select.dispose
    @buy.dispose
    @total.bitmap.dispose
    @total.dispose
    @name.dispose
    @card_num_text.dispose
    @bg_frame.dispose
    @actor.dispose
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
    @buy.update
    #@actor_select.update
    @battle.update
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
      @master.on_actor_select
    end
    if Input.trigger?(:C)
      @current_page.process_ok
      puts "已觸發確認鍵"
      if @buy.on 
        Sound.play_ok
        @master.on_goto_buy
      end
      # 下一頁偵測
      if @page_btns[0].on && @page_btns[0].visible
        change_index(1)
      end
      # 上一頁偵測
      if @page_btns[1].on && @page_btns[1].visible
        change_index(0)
      end
      #if @actor_select.on
      #  @master.on_actor_select
      #end
      if @battle.on
        Sound.play_ok
        @master.on_goto_battle
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
  # ● 刷新總數字
  #--------------------------------------------------------------------------
  def refresh_total_number
    @total.bitmap.clear
    # 繪製左邊
    current = actor.card_number
    if current == CardBattle::MIN_CARD_NUMBER
      color = @total.text_color(2)
    elsif current == CardBattle::MAX_CARD_NUMBER
      color = @total.text_color(6)
    else
      color = @total.normal_color
    end
    @total.change_color(color)
    rect = @total.bitmap.rect.clone
    rect.width -= 50
    @total.draw_text(rect,current,2)
    # 繪製右邊
    @total.change_color(@total.normal_color)
    @total.draw_text(@total.bitmap.rect,"/ #{CardBattle::MAX_CARD_NUMBER}",2)
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
    refresh_total_number
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
end
end
