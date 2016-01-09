#encoding:utf-8
#==============================================================================
# ■ CardBattle::Spriteset_CardBattle
#------------------------------------------------------------------------------
# 　管理卡牌戰鬥畫面中的總精靈組
#     內部由多個精靈組所組成
#     此精靈組統一管理所有的Viewport建立
#==============================================================================
module CardBattle
class Spriteset_CardBattle
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @input_phase = :nil
    create_viewport
    create_spritesets
    update
  end
  #--------------------------------------------------------------------------
  # ● 產生顯示端口
  #--------------------------------------------------------------------------
  def create_viewport
    @viewport_bg = Viewport.new
    @viewport_card = Viewport.new
    @viewport_overlap_input = Viewport.new
    @viewport_cut_in = Viewport.new
    @viewport_bg.z = 0
    @viewport_card.z = 100
    @viewport_overlap_input.z = 500
    @viewport_cut_in.z = 600
    
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈組
  #--------------------------------------------------------------------------
  def create_spritesets
    create_background
    create_card_spriteset
    create_input_spriteset
    create_hp_spriteset
    create_cut_in_sprite
    create_actor_spriteset
    create_sum_spriteset
    create_replenish
    create_action_success
    create_battle_counter
  end
  #--------------------------------------------------------------------------
  # ● 產生背景精靈組
  #--------------------------------------------------------------------------
  def create_background
    @bg_spriteset = Spriteset_BattleBackground.new(@viewport_bg)
  end
  #--------------------------------------------------------------------------
  # ● 產生卡牌精靈組
  #--------------------------------------------------------------------------
  def create_card_spriteset
    # 玩家卡牌
    @player_card_spriteset = Spriteset_PlayerBattleCards.new(self,@viewport_card)
    # 敵人卡牌
    @enemy_card_spriteset = Spriteset_EnemyBattleCards.new(self,@viewport_card)
  end
  #--------------------------------------------------------------------------
  # ● 產生輸入精靈組
  #--------------------------------------------------------------------------
  def create_input_spriteset
    # 模式選擇精靈組
    @mode_input_select_spriteset = Spriteset_BattleModeSelect.new(@viewport_overlap_input)
    @mode_input_select_spriteset.input_mode_handler = method(:input_mode_handler)
    
    # 卡片選擇精靈組
    @card_input_select_spriteset = Spriteset_BattleCardSelect.new(self,@viewport_overlap_input)
    @card_input_select_spriteset.input_handler = method(:input_card_handler)
  
    # 保留選擇精靈組
    @reserve_input_select_spriteset = Spriteset_ReserveCardSelect.new(@viewport_overlap_input)
    @reserve_input_select_spriteset.input_handler = method(:input_reserve_handler)
    
  end
  #--------------------------------------------------------------------------
  # ● 產生生命值精靈組
  #--------------------------------------------------------------------------
  def create_hp_spriteset
    @player_hp_spriteset = Spriteset_BattleHp.new(CardBattleManager.p_cards,@viewport_card)
    @enemy_hp_spriteset = Spriteset_BattleHp.new(CardBattleManager.e_cards,@viewport_card)
  end
  #--------------------------------------------------------------------------
  # ● 產生技能精靈
  #--------------------------------------------------------------------------
  def create_cut_in_sprite
    @cut_in_sprite = Sprite_UltSkill.new(@viewport_cut_in)
  end
  #--------------------------------------------------------------------------
  # ● 產生角色肖像精靈
  #--------------------------------------------------------------------------
  def create_actor_spriteset
    @player_face_spriteset = Spriteset_BattleActorFace.new(CardBattleManager.p_cards,@viewport_bg)
    @enemy_face_spriteset = Spriteset_BattleActorFace.new(CardBattleManager.e_cards,@viewport_bg)
  end
  #--------------------------------------------------------------------------
  # ● 產生點數總和精靈
  #--------------------------------------------------------------------------
  def create_sum_spriteset
    @player_sum_spriteset = Spriteset_BattleCardSum.new(CardBattleManager.p_cards,@viewport_overlap_input)
    @enemy_sum_spriteset = Spriteset_BattleCardSum.new(CardBattleManager.e_cards,@viewport_overlap_input)
  end
  #--------------------------------------------------------------------------
  # ● 產生補充精靈
  #--------------------------------------------------------------------------
  def create_replenish
    @replenish = Spriteset_BattleReplenish.new(self,@viewport_overlap_input)
  end
  #--------------------------------------------------------------------------
  # ● 產生連續行動精靈
  #--------------------------------------------------------------------------
  def create_action_success
    @action_success = Spriteset_BattleActionSuccess.new(self,@viewport_overlap_input)
  end
  #--------------------------------------------------------------------------
  # ● 產生戰鬥計數器
  #--------------------------------------------------------------------------
  def create_battle_counter
    @p_counter = Spriteset_BattleCounter.new(CardBattleManager.p_cards,@viewport_card)
    @e_counter = Spriteset_BattleCounter.new(CardBattleManager.e_cards,@viewport_card)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    dispose_battle_counter
    dispose_action_success
    dispose_replenish
    dispose_sum_spriteset
    dispose_actor_spriteset
    dispose_cut_in_sprite
    dispose_background
    dispose_card_spriteset
    dispose_input_spriteset
    dispose_hp_spriteset
    dispose_viewport
    GC.start
  end
  #--------------------------------------------------------------------------
  # ● 釋放顯示端口
  #--------------------------------------------------------------------------
  def dispose_viewport
    @viewport_bg.dispose
    @viewport_card.dispose
    @viewport_overlap_input.dispose
    @viewport_cut_in.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景精靈組
  #--------------------------------------------------------------------------
  def dispose_background
    @bg_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放卡牌精靈組
  #--------------------------------------------------------------------------
  def dispose_card_spriteset
    @player_card_spriteset.dispose
    @enemy_card_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放輸入精靈組
  #--------------------------------------------------------------------------
  def dispose_input_spriteset
    @mode_input_select_spriteset.dispose
    @card_input_select_spriteset.dispose
    @reserve_input_select_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放生命值精靈組
  #--------------------------------------------------------------------------
  def dispose_hp_spriteset
    @player_hp_spriteset.dispose
    @enemy_hp_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放技能精靈
  #--------------------------------------------------------------------------
  def dispose_cut_in_sprite
    @cut_in_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放角色肖像精靈
  #--------------------------------------------------------------------------
  def dispose_actor_spriteset
    @player_face_spriteset.dispose
    @enemy_face_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放點數總和精靈
  #--------------------------------------------------------------------------
  def dispose_sum_spriteset
    @player_sum_spriteset.dispose
    @enemy_sum_spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放補充精靈
  #--------------------------------------------------------------------------
  def dispose_replenish
    @replenish.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放連續行動精靈
  #--------------------------------------------------------------------------
  def dispose_action_success
    @action_success.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放戰鬥計數器
  #--------------------------------------------------------------------------
  def dispose_battle_counter
    @p_counter.dispose
    @e_counter.dispose
  end

  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_background
    update_card_spriteset
    update_input_mode
    update_hp_spriteset
    update_cut_in_sprite
    update_actor_spriteset
    update_sum_spriteset
    update_replenish
    update_action_success
    update_battle_counter
    update_viewport
  end
  #--------------------------------------------------------------------------
  # ● 更新顯示端口
  #--------------------------------------------------------------------------
  def update_viewport
    @viewport_card.update
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精靈組
  #--------------------------------------------------------------------------
  def update_background
    @bg_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新卡牌精靈組
  #--------------------------------------------------------------------------
  def update_card_spriteset
    @player_card_spriteset.update
    @enemy_card_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新生命值精靈組
  #--------------------------------------------------------------------------
  def update_hp_spriteset
    @player_hp_spriteset.update
    @enemy_hp_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新技能精靈
  #--------------------------------------------------------------------------
  def update_cut_in_sprite
    @cut_in_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新角色肖像精靈
  #--------------------------------------------------------------------------
  def update_actor_spriteset
    @player_face_spriteset.update
    @enemy_face_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新點數總和精靈
  #--------------------------------------------------------------------------
  def update_sum_spriteset
    @player_sum_spriteset.update
    @enemy_sum_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新補充精靈
  #--------------------------------------------------------------------------
  def update_replenish
    @replenish.update
  end
  #--------------------------------------------------------------------------
  # ● 更新連續行動精靈
  #--------------------------------------------------------------------------
  def update_action_success
    @action_success.update
  end
  #--------------------------------------------------------------------------
  # ● 更新戰鬥計數器
  #--------------------------------------------------------------------------
  def update_battle_counter
    @p_counter.update
    @e_counter.update
  end  
  #--------------------------------------------------------------------------
  # ● 更新模式輸入
  #--------------------------------------------------------------------------
  def update_input_mode
    case @input_phase
    when :select_require
      active_mode_select_spriteset
      @input_phase = :select
    when :select
      #puts "更新輸入模式..."
      update_mode_select_spriteset
    when :card_select_require
      #puts "進入卡片選擇"
      active_card_select_spriteset
      @input_phase = :card_select
    when :card_select
      #puts "更新卡片選擇"
      update_card_select_spriteset
    when :reserve_select_require
      #puts "進入保留選擇"
      active_reserve_select_spriteset
      @input_phase = :reserve_select
    when :reserve_select
      #puts "更新卡片選擇"
      update_reserve_select_spriteset
    when :redraw_player
      #puts "更新玩家重抽階段"
      update_redraw_player
    when :redraw_enemy
      #puts "更新敵人重抽階段"
      update_redraw_enemy
    when :reselect_enemy
      #puts "更新敵人重選階段"
      update_reselect_enemy
    when :exchange
      #puts "更新卡片交換"
      update_card_exchange
    end
  end
  #--------------------------------------------------------------------------
  # ● 啟用模式選擇精靈組
  #--------------------------------------------------------------------------
  def active_mode_select_spriteset
    @mode_input_select_spriteset.start_input
  end
  #--------------------------------------------------------------------------
  # ● 啟用卡片選擇精靈組
  #--------------------------------------------------------------------------
  def active_card_select_spriteset
    @card_input_select_spriteset.start_input(@player_card_spriteset)
  end
  #--------------------------------------------------------------------------
  # ● 啟用保留選擇精靈組
  #--------------------------------------------------------------------------
  def active_reserve_select_spriteset
    @reserve_input_select_spriteset.start_input(@player_card_spriteset)
  end

  #--------------------------------------------------------------------------
  # ● 模式輸入函數 (由輸入精靈呼叫)
  #--------------------------------------------------------------------------
  def input_mode_handler(mode)
    puts "選擇模式：#{mode}"
    if @target_mode_set
      puts "設定模式：#{@target_mode_set.class}為#{mode}"
      @target_mode_set.set_battle_mode(mode)
    end
    @input_phase = :nil
  end
  #--------------------------------------------------------------------------
  # ● 卡片輸入函數 (由輸入精靈呼叫)
  #   此為確認精靈，該選的牌在此時都必須已經列入flag之中
  #--------------------------------------------------------------------------
  def input_card_handler
    puts "卡片已確認"
    @input_phase = :nil
  end
  #--------------------------------------------------------------------------
  # ● 保留輸入函數 (由輸入精靈呼叫)
  #   此為確認精靈，該選的牌在此時都必須已經列入flag之中
  #--------------------------------------------------------------------------
  def input_reserve_handler
    puts "保留已確認"
    @input_phase = :nil
  end
  #--------------------------------------------------------------------------
  # ● 更新模式選擇精靈組
  #--------------------------------------------------------------------------
  def update_mode_select_spriteset
    @mode_input_select_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新卡片選擇精靈組
  #--------------------------------------------------------------------------
  def update_card_select_spriteset
    @card_input_select_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新保留選擇精靈組
  #--------------------------------------------------------------------------
  def update_reserve_select_spriteset
    @reserve_input_select_spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def effect?
    return true if @replenish.effect?
    return true if @action_success.effect?
    return true if @player_card_spriteset.effect?
    return true if @enemy_card_spriteset.effect?
    return true if @player_hp_spriteset.effect?
    return true if @enemy_hp_spriteset.effect?
    return true if @cut_in_sprite.effect?
    return true if @enemy_sum_spriteset.effect?
    return true if @player_sum_spriteset.effect?
    return true if @p_counter.effect?
    return true if @e_counter.effect?  
    

    return false
  end
  #--------------------------------------------------------------------------
  # ● 卡組是否動畫中？
  #--------------------------------------------------------------------------
  def cardset_animation?
    return true if @player_card_spriteset.animation?
    return true if @enemy_card_spriteset.animation?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 是否輸入中？
  #--------------------------------------------------------------------------
  def input?
    return true if @input_phase != :nil
    return false
  end
  #--------------------------------------------------------------------------
  # ● 玩家發牌
  #--------------------------------------------------------------------------
  def player_deliver
    @player_card_spriteset.set_deliver
  end
  #--------------------------------------------------------------------------
  # ● 敵人發牌
  #--------------------------------------------------------------------------
  def enemy_deliver
    @enemy_card_spriteset.set_deliver
  end
  #--------------------------------------------------------------------------
  # ● 玩家保留牌
  #--------------------------------------------------------------------------
  def player_reserve
    @player_card_spriteset.set_reserve
  end
  #--------------------------------------------------------------------------
  # ● 敵人保留牌
  #--------------------------------------------------------------------------
  def enemy_reserve
    @enemy_card_spriteset.set_reserve
  end
  #--------------------------------------------------------------------------
  # ● 將敵人的牌移動至出牌區
  #--------------------------------------------------------------------------
  def enemy_card_move_to_ready
    @enemy_card_spriteset.effect_move_to_ready
  end
  #--------------------------------------------------------------------------
  # ● 清除場上已出的牌 ( 隱藏精靈 & 歸位 )   
  #--------------------------------------------------------------------------
  def clear_selected_card
    @enemy_card_spriteset.clear_selected_card
    @player_card_spriteset.clear_selected_card
  end
  #--------------------------------------------------------------------------
  # ● 開始模式輸入
  #--------------------------------------------------------------------------
  def start_input_mode_for(set_object)
    @input_phase = :select_require
    @target_mode_set = set_object
  end
  #--------------------------------------------------------------------------
  # ● 開始卡片選擇輸入
  #--------------------------------------------------------------------------
  def start_input_card_for(set_object)
    @input_phase = :card_select_require
    @target_card_set = set_object
  end
  #--------------------------------------------------------------------------
  # ● 開始卡片保留輸入
  #--------------------------------------------------------------------------
  def start_input_reserve_for(set_object)
    @input_phase = :reserve_select_require
    @target_card_set = set_object
  end
  #--------------------------------------------------------------------------
  # ● 清除玩家已出戰的牌
  #--------------------------------------------------------------------------
  def clear_player_selected_card
    @player_card_spriteset.clear_selected_card
  end
  #--------------------------------------------------------------------------
  # ● 改變階段到玩家重抽階段
  #--------------------------------------------------------------------------
  def phase_to_redraw_player
    @input_phase = :redraw_player
  end
  #--------------------------------------------------------------------------
  # ● 改變階段到敵人重抽階段
  #--------------------------------------------------------------------------
  def phase_to_redraw_enemy
    @input_phase = :redraw_enemy
  end
  #--------------------------------------------------------------------------
  # ● 玩家卡片精靈清除
  #--------------------------------------------------------------------------
  def player_card_redraw_clear
    @player_card_spriteset.redraw_clear_sprite_to_outside
  end
  #--------------------------------------------------------------------------
  # ● 敵人卡片精靈清除
  #--------------------------------------------------------------------------
  def enemy_card_redraw_clear
    @enemy_card_spriteset.redraw_clear_sprite_to_outside
  end

  #--------------------------------------------------------------------------
  # ● 開始玩家卡片重抽
  #--------------------------------------------------------------------------
  def start_redraw_for_player
    puts "玩家開始重抽"
    phase_to_redraw_player
    CardBattleManager.p_cards.deliver_card # 執行發卡
    @player_card_spriteset.clear_card_sprite_data
    player_deliver
  end
  #--------------------------------------------------------------------------
  # ● 開始敵人卡片重抽
  #--------------------------------------------------------------------------
  def start_redraw_for_enemy
    puts "敵人開始重抽"
    phase_to_redraw_enemy
    CardBattleManager.e_cards.deliver_card(false) # 執行發卡
    @enemy_card_spriteset.clear_card_sprite_data
    enemy_deliver
  end
  #--------------------------------------------------------------------------
  # ● 更新玩家卡片重抽
  #--------------------------------------------------------------------------
  def update_redraw_player
    #puts "更新玩家重抽..."
    if !effect?
      # 如果效果停止了
      puts "結束玩家卡片重抽"
      @input_phase = :card_select_require
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新敵人卡片重抽
  #--------------------------------------------------------------------------
  def update_redraw_enemy
    #puts "更新敵人重抽..."
    if !effect?
      # 如果效果停止了
      puts "結束敵人卡片重抽，開始重選"
      @input_phase = :reselect_enemy
      # 設定重選資訊
      CardBattleManager.e_cards.auto_select_card
      enemy_card_move_to_ready
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新敵人卡片重選
  #--------------------------------------------------------------------------
  def update_reselect_enemy
    #puts "更新敵人重選..."
    if !effect?
      # 如果效果停止了
      puts "結束敵人卡片重選"
      @input_phase = :card_select_require
    end
  end
  #--------------------------------------------------------------------------
  # ● 卡片交換，將卡片移至交換離開區
  #--------------------------------------------------------------------------
  def card_table_exchange_clear
    @player_card_spriteset.sprite_clear_for_exchange
    @enemy_card_spriteset.sprite_clear_for_exchange
  end
  #--------------------------------------------------------------------------
  # ● 開始卡片交換
  #--------------------------------------------------------------------------
  def start_exchange
    @input_phase = :exchange
     CardBattleManager.exchange_card_table
     @player_card_spriteset.set_card_table_on_sprite
     @enemy_card_spriteset.set_card_table_on_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新卡片交換
  #--------------------------------------------------------------------------
  def update_card_exchange
    #puts "更新卡片交換..."
    if !effect?
      # 如果效果停止了
      puts "結束卡片交換，敵人開始重選"
      @input_phase = :reselect_enemy
      # 設定重選資訊
      CardBattleManager.e_cards.auto_select_card
      enemy_card_move_to_ready
    end
  end
  #--------------------------------------------------------------------------
  # ● 攤牌
  #--------------------------------------------------------------------------
  def show_card
    @player_card_spriteset.show_card
    @enemy_card_spriteset.show_card
  end
  #--------------------------------------------------------------------------
  # ● 顯示玩家技能效果
  #--------------------------------------------------------------------------
  def show_player_skill_effect
    if @player_card_spriteset.card_set.battle_mode == :attack #@player_card_spriteset.card_set.skill_enable
      b_id = @player_card_spriteset.card_set.battler_id
      if @player_card_spriteset.card_set.skill_enable
        # 大招
        name = "Cut-in_Actor#{b_id}_Skill"
      else
        # 普攻
        name = "Cut-in_Actor#{b_id}_Attack"
      end
      @cut_in_sprite.set_ult_picture(name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示敵人技能效果
  #--------------------------------------------------------------------------
  def show_enemy_skill_effect
    if @enemy_card_spriteset.card_set.battle_mode == :attack #@enemy_card_spriteset.card_set.skill_enable
      b_id = @enemy_card_spriteset.card_set.battler_id
      name = "Cut-in_Enemy#{b_id}_Attack"
      @cut_in_sprite.set_ult_picture(name)
    end

  end

  #--------------------------------------------------------------------------
  # ● 玩家顯示為攻擊
  #--------------------------------------------------------------------------
  def player_show_battle_mode
    @player_face_spriteset.show_battle_mode
  end
  #--------------------------------------------------------------------------
  # ● 玩家隱藏模式
  #--------------------------------------------------------------------------
  def player_hide_battle_mode
    @player_face_spriteset.hide_battle_mode
  end
  #--------------------------------------------------------------------------
  # ● 敵人顯示為攻擊
  #--------------------------------------------------------------------------
  def enemy_show_battle_mode
    @enemy_face_spriteset.show_battle_mode
  end
  #--------------------------------------------------------------------------
  # ● 敵人隱藏模式
  #--------------------------------------------------------------------------
  def enemy_hide_battle_mode
    @enemy_face_spriteset.hide_battle_mode
  end
  #--------------------------------------------------------------------------
  # ● 取得對應卡片精靈
  #--------------------------------------------------------------------------
  def correspond_card_set_sprite(card_set)
    if card_set.is_a?(Game_PlayerCardSet)
      return @player_card_spriteset
    else
      return @enemy_card_spriteset
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示卡片動畫
  #--------------------------------------------------------------------------
  def show_card_animation(card_set)
    # 設定卡片動畫
    ani_id = 0
    case card_set.battle_mode
    when :attack
      ani_id = 81
    when :defend
      ani_id = 119
    end
    correspond_card_set_sprite(card_set).selected_card_sprites.each do |sprite|
      sprite.start_animation_id(ani_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵人顯示卡片總和
  #--------------------------------------------------------------------------
  def show_enemy_card_sum
    @enemy_sum_spriteset.show_card_sum
    show_card_animation(CardBattleManager.e_cards)
  end
  #--------------------------------------------------------------------------
  # ● 玩家顯示卡片總和
  #--------------------------------------------------------------------------
  def show_player_card_sum
    @player_sum_spriteset.show_card_sum
    show_card_animation(CardBattleManager.p_cards)
  end
  #--------------------------------------------------------------------------
  # ● 敵人隱藏卡片總和
  #--------------------------------------------------------------------------
  def hide_enemy_card_sum
    @enemy_sum_spriteset.hide_card_sum
  end
  #--------------------------------------------------------------------------
  # ● 玩家隱藏卡片總和
  #--------------------------------------------------------------------------
  def hide_player_card_sum
    @player_sum_spriteset.hide_card_sum
  end
  #--------------------------------------------------------------------------
  # ● 顯示卡牌補充
  #--------------------------------------------------------------------------
  def show_replenish
    @replenish.show
  end
  #--------------------------------------------------------------------------
  # ● 顯示連續行動
  #--------------------------------------------------------------------------
  def show_action_success(mode)
    @action_success.show(mode)
  end


end
end