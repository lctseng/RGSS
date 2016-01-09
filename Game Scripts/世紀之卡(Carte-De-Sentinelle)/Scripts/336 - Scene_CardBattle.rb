#encoding:utf-8
#==============================================================================
# ■ CardBattle::Scene_CardBattle
#------------------------------------------------------------------------------
# 　卡片戰鬥場景
#==============================================================================

module CardBattle
class Scene_CardBattle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 是否讀取紀錄的標誌
  #--------------------------------------------------------------------------
  @@load_record = false
  #--------------------------------------------------------------------------
  # ● 設置讀取紀錄
  #--------------------------------------------------------------------------
  def self.set_load_record
    @@load_record = true
  end
  #--------------------------------------------------------------------------
  # ● 獲取漸變速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 30
  end
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    process_load_record
    CardBattleManager.setup
    @spriteset = Spriteset_CardBattle.new
    puts "玩家戰鬥類型：#{player_set.battler_type}"
    puts "敵人戰鬥類型：#{enemy_set.battler_type}"
  end
  #--------------------------------------------------------------------------
  # ● 處理紀錄讀取
  #--------------------------------------------------------------------------
  def process_load_record
    need_save = true
    if @@load_record
      puts "讀取戰鬥紀錄"
      if DataManager.save_file_exists_index?(BATTLE_SAVE_INDEX)
        DataManager.load_game(BATTLE_SAVE_INDEX)
        if !$game_system.battle_only
          msgbox "記錄檔遺失或損毀"
          SceneManager.exit
        end
        need_save = false
      else
        puts "記錄檔不存在！"
        msgbox "記錄檔遺失或損毀"
        SceneManager.exit
      end
      @@load_record = false
    end
    if need_save
      $game_system.battle_only = true
      DataManager.save_game(BATTLE_SAVE_INDEX)
    end
    $game_system.battle_only = false
  end
  #--------------------------------------------------------------------------
  # ● 取得主流程
  #--------------------------------------------------------------------------
  def main_phase
    CardBattleManager.main_phase
  end
  #--------------------------------------------------------------------------
  # ● 取得副流程
  #--------------------------------------------------------------------------
  def sub_phase
    CardBattleManager.sub_phase
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主流程判斷)
  #--------------------------------------------------------------------------
  def update
    super
    puts "主：#{CardBattleManager.main_phase} 副：#{CardBattleManager.sub_phase}"
    case main_phase
    when :init # 戰鬥初始化
      process_init
    when :turn_start # 回合開始 (每個回合由此開始)
      process_turn_start
    when :card_deliver # 發卡
      case sub_phase
      when :init # 初始化發卡
        prcocess_init_deliver
      when :player # 玩家發卡
        deliver_card_player
      when :enemy # 敵人發卡
        deliver_card_enemy
      end
    when :mode_select # 模式選擇
      case sub_phase
      when :init # 初始化模式選擇
        process_mode_select_init
      when :player # 玩家選模式
        process_mode_select_player
      when :enemy # 敵人選模式
        process_mode_select_enemy
      when :end # 模式選擇結束
        process_mode_select_end
      end
    when :select_card # 卡片選擇
      case sub_phase
      when :init # 初始化
        process_select_card_init
      when :enemy_card # 敵人選卡
        process_select_card_enemy
      when :enemy_end # 敵人選完
        process_select_card_enemy_end
      when :player_card # 玩家選卡
        process_select_card_player
      when :player_end # 玩家選完
        process_select_card_player_end
      when :end # 選卡結束
        process_select_card_end
      end
    when :battle # 戰鬥階段
      case sub_phase
      when :show_card # 攤牌
        process_battle_show_card
      when :player_effect # 玩家效果
        process_battle_player_effect
      when :enemy_effect # 敵人效果
        process_battle_enemy_effect
      when :execute # 執行傷害
        process_battle_execute
      end
    when :judge # 回合結果判斷
      process_battle_judge
    when :turn_restart # 回合重新開始
      case sub_phase
      when :player_reserve
        process_player_reserve
      when :enemy_reserve
        process_enemy_reserve
      when :end
        process_end_turn_restart
      end
    when :win
      process_win # 勝利處理
    when :loss
      process_loss # 戰敗處理
    when :end # 戰鬥結束
      process_end_battle
    end
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面(基礎)
  #--------------------------------------------------------------------------
  def update_basic
    super
    ## DEBUG # TODO
    if Input.trigger?(:L) && $TEST
      CardBattleManager.p_cards.open_attack_combo
      #CardBattleManager.process_loss(:hp)
      #SceneManager.call(Scene_BattleLose)
      CardBattleManager.process_win
      SceneManager.call(Scene_BattleWin)
    end
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # ● 更新等待
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    puts "等待：#{duration}"
    if Input.press?(:A)
      duration = 10
    end
    duration.times do |i|
      #puts "等待...#{i}/#{duration}"
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待輸入確認鍵
  #--------------------------------------------------------------------------
  def wait_for_ok
    puts "等待確認鍵..."
    until Input.trigger?(:C)
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待精靈處理
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    while @spriteset.effect?
      #puts "等待精靈處理"
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 等待精靈處理卡組動畫
  #--------------------------------------------------------------------------
  def wait_for_cardset_animation
    update_for_wait
    while @spriteset.cardset_animation?
      #puts "等待精靈處理卡組動畫"
      update_for_wait
    end
  end

  #--------------------------------------------------------------------------
  # ● 等待輸入
  #--------------------------------------------------------------------------
  def wait_for_input
    #puts "等待輸入"
    update_for_wait
    while @spriteset.input?
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 初始化處理
  #--------------------------------------------------------------------------
  def process_init
    #wait_for_ok
    enter_turn_start
  end
  #--------------------------------------------------------------------------
  # ● 進入回合開始階段
  #--------------------------------------------------------------------------
  def enter_turn_start
    CardBattleManager.turn_start
  end
  #--------------------------------------------------------------------------
  # ● 回合開始
  #--------------------------------------------------------------------------
  def process_turn_start
    puts "第 #{CardBattleManager.turn_count} 回合開始"
    CardBattleManager.p_cards.turn_start
    CardBattleManager.e_cards.turn_start
    
    enter_card_deliver
  end
  #--------------------------------------------------------------------------
  # ● 進入發卡階段
  #--------------------------------------------------------------------------
  def enter_card_deliver
    CardBattleManager.phase_card_deliver
  end
  #--------------------------------------------------------------------------
  # ● 初始化發卡
  #--------------------------------------------------------------------------
  def prcocess_init_deliver
    puts "準備發卡..."
    start_player_deliver
  end
  #--------------------------------------------------------------------------
  # ● 玩家發卡開始
  #--------------------------------------------------------------------------
  def  start_player_deliver
    CardBattleManager.phase_start_player_card
  end

  #--------------------------------------------------------------------------
  # ● 發卡 - 玩家
  #--------------------------------------------------------------------------
  def deliver_card_player
    puts "發卡：玩家"
    CardBattleManager.p_cards.deliver_card # 執行發卡
    if CardBattleManager.p_cards.have_replenish
      @spriteset.show_replenish
      wait_for_effect
    end
    @spriteset.player_deliver
    wait_for_effect
    #wait_for_ok
    end_player_deliver
  end
  #--------------------------------------------------------------------------
  # ● 玩家發卡結束
  #--------------------------------------------------------------------------
  def  end_player_deliver
    CardBattleManager.phase_end_player_card
  end
  #--------------------------------------------------------------------------
  # ● 發卡 - 敵人
  #--------------------------------------------------------------------------
  def deliver_card_enemy
    puts "發卡：敵人"
    CardBattleManager.e_cards.deliver_card(false) # 執行發卡
    @spriteset.enemy_deliver
    wait_for_effect
    end_enemy_deliver
  end
  #--------------------------------------------------------------------------
  # ● 敵人發卡結束
  #--------------------------------------------------------------------------
  def  end_enemy_deliver
    CardBattleManager.phase_end_enemy_card
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥結束處理
  #--------------------------------------------------------------------------
  def process_end_battle
    #wait_for_ok
    CardBattleManager.replay_bgm_and_bgs
    return_scene
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇：初始化
  #--------------------------------------------------------------------------
  def process_mode_select_init
    puts "模式選擇：初始化"
    CardBattleManager.phase_end_mode_init
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇：玩家
  #--------------------------------------------------------------------------
  def process_mode_select_player
    puts "模式選擇：玩家"
    @spriteset.start_input_mode_for(CardBattleManager.p_cards)
    wait_for_input
    # CardBattleManager.p_cards.auto_select_mode
    #wait_for_ok
    CardBattleManager.phase_end_mode_player
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇：敵人
  #--------------------------------------------------------------------------
  def process_mode_select_enemy
    puts "模式選擇：敵人"
    CardBattleManager.e_cards.auto_select_mode
    CardBattleManager.phase_end_mode_enemy
  end
  #--------------------------------------------------------------------------
  # ● 模式選擇：結束
  #--------------------------------------------------------------------------
  def process_mode_select_end
    puts "模式選擇：結束"
    @spriteset.player_show_battle_mode
    CardBattleManager.phase_end_mode_end
  end
  #--------------------------------------------------------------------------
  # ● 卡片選擇初始化
  #--------------------------------------------------------------------------
  def process_select_card_init
    puts "初始化選擇卡片..."
    CardBattleManager.phase_end_card_select_init
    
  end

  #--------------------------------------------------------------------------
  # ● 玩家卡片選擇
  #--------------------------------------------------------------------------
  def process_select_card_player
    puts "玩家選擇卡片"
    #CardBattleManager.p_cards.auto_select_card
    @spriteset.start_input_card_for(CardBattleManager.p_cards)
    wait_for_input
    CardBattleManager.p_cards.determine_cards
    CardBattleManager.phase_end_card_select_player
  end
  #--------------------------------------------------------------------------
  # ● 玩家卡片選擇結束
  #--------------------------------------------------------------------------
  def process_select_card_player_end
    puts "玩家選擇卡片已結束"
    CardBattleManager.phase_end_card_select_player_end
  end
  #--------------------------------------------------------------------------
  # ● 敵人卡片選擇
  #--------------------------------------------------------------------------
  def process_select_card_enemy
    puts "敵人選擇卡片..."
    CardBattleManager.e_cards.auto_select_card
    @spriteset.enemy_card_move_to_ready
    wait_for_effect
    CardBattleManager.phase_end_card_select_enemy
  end
  #--------------------------------------------------------------------------
  # ● 敵人卡片選擇結束
  #--------------------------------------------------------------------------
  def process_select_card_enemy_end
    puts "敵人選擇卡片已結束"
    CardBattleManager.phase_end_card_select_enemy_end
  end
  #--------------------------------------------------------------------------
  # ● 卡片選擇結束
  #--------------------------------------------------------------------------
  def process_select_card_end
    puts "雙方選擇卡片已結束"
    CardBattleManager.phase_end_card_select_end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥：雙方攤牌
  #--------------------------------------------------------------------------
  def process_battle_show_card
    puts "雙方攤牌"
    @spriteset.enemy_show_battle_mode
    @spriteset.show_card
    # 產生點數總和
    CardBattleManager.e_cards.generate_point_sum
    CardBattleManager.p_cards.generate_point_sum
    # 產生誰要顯示圖片
    decide_picture_to_show
    # 顯示敵人點數總和
    @spriteset.show_enemy_card_sum
    wait_for_effect
    # 顯示玩家點數總和
    @spriteset.show_player_card_sum
    wait_for_effect
    wait_for_cardset_animation
    CardBattleManager.phase_end_battle_show_card
  end
  #--------------------------------------------------------------------------
  # ● 決定顯示的圖片
  #--------------------------------------------------------------------------
  def decide_picture_to_show
    @hide_enemy_effect = false
    @hide_player_effect = false
    # 雙方都攻擊時，會產生雙方圖片都出現的情況
    if CardBattleManager.e_cards.battle_mode == :attack && CardBattleManager.p_cards.battle_mode == :attack
      if CardBattleManager.p_cards.point_sum > CardBattleManager.e_cards.point_sum
        # 玩家比較大，隱藏敵人
        @hide_enemy_effect = true
      elsif CardBattleManager.p_cards.point_sum < CardBattleManager.e_cards.point_sum
        @hide_player_effect = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥：玩家效果
  #--------------------------------------------------------------------------
  def process_battle_player_effect
    puts "玩家效果"
    if !@hide_player_effect
      @spriteset.show_player_skill_effect
      wait_for_effect
    end
    CardBattleManager.phase_end_battle_player_effect
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥：敵人效果
  #--------------------------------------------------------------------------
  def process_battle_enemy_effect
    puts "敵人效果"
    if !@hide_enemy_effect
      @spriteset.show_enemy_skill_effect
      wait_for_effect
    end
    CardBattleManager.phase_end_battle_enemy_effect
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥：執行傷害
  #--------------------------------------------------------------------------
  def process_battle_execute
    puts "執行傷害"
    puts "玩家模式：#{CardBattleManager.p_cards.battle_mode}，點數：#{CardBattleManager.p_cards.point_sum}"
    puts "敵人模式：#{CardBattleManager.e_cards.battle_mode}，點數：#{CardBattleManager.e_cards.point_sum}"

    case CardBattleManager.p_cards.battle_mode
    when :attack # 玩家攻擊
      # 檢查敵人行動
      case CardBattleManager.e_cards.battle_mode
      when :attack # 敵人攻擊
        process_attack_attack
      when :defend # 敵人防禦
        process_attack_defend
      end
      # 設置防禦點數
      CardBattleManager.p_cards.add_defend_point(0)
    when :defend # 玩家防禦
      # 檢查敵人行動
      case CardBattleManager.e_cards.battle_mode
      when :attack # 敵人攻擊
        process_defend_attack
      when :defend # 敵人防禦
        process_defend_defend
      end
      # 設置防禦點數
      CardBattleManager.p_cards.add_defend_point(CardBattleManager.p_cards.point_sum)
    end
    wait_for_effect
    call_for_success = CardBattleManager.p_cards.call_for_success
    if call_for_success
      CardBattleManager.p_cards.call_for_success = nil
      @spriteset.show_action_success(call_for_success)
    end
    wait_for_effect
    CardBattleManager.p_cards.post_battle_execute
    CardBattleManager.e_cards.post_battle_execute
    @spriteset.hide_player_card_sum
    @spriteset.hide_enemy_card_sum
    #wait_for_ok
    #clear_selected_card # 清除戰鬥場上已出的牌 (精靈效果)
    CardBattleManager.phase_end_battle_execute
  end
  #--------------------------------------------------------------------------
  # ● 清除戰鬥場上已出的牌 (精靈效果)
  #--------------------------------------------------------------------------
  def clear_selected_card 
    @spriteset.clear_selected_card
    wait_for_effect
  end
  #--------------------------------------------------------------------------
  # ● 處理雙方皆攻擊
  #--------------------------------------------------------------------------
  def process_attack_attack
    puts "雙方皆發動攻擊！"
    diff = CardBattleManager.point_diff
    if diff > 0
      puts "玩家攻擊超越#{diff}點！"
      CardBattleManager.player_attack_success(diff)
    elsif diff < 0
      diff*= -1
      puts "敵方攻擊超越#{diff}點！"
      CardBattleManager.player_attack_failure
      CardBattleManager.enemy_attack_success(diff)
    else
      puts "雙方攻擊相同！"
      CardBattleManager.action_even
      CardBattleManager.player_attack_even
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理雙方皆防禦
  #--------------------------------------------------------------------------
  def process_defend_defend
    puts "雙方皆發動防禦！"
    CardBattleManager.action_even
    CardBattleManager.player_defend_even
    pp = CardBattleManager.p_cards.point_sum
    ep  =  CardBattleManager.e_cards.point_sum
    if pp > ep
      CardBattleManager.player_defend_success((ep * 0.3).round)
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理玩家攻擊敵方防禦
  #--------------------------------------------------------------------------
  def process_attack_defend
    puts "玩家攻擊，敵方防禦！"
    if player_set.ignore_defend_ok?
      ignore_list = [false,true]
    else
      ignore_list = [false,false]
    end
    diff = CardBattleManager.point_diff(*ignore_list)
    if diff > 0
      puts "玩家攻擊超越#{diff}點！"
      CardBattleManager.player_attack_success(diff)
    else
      CardBattleManager.player_attack_failure
      CardBattleManager.player_attack_blocked
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理我方防禦敵方攻擊
  #--------------------------------------------------------------------------
  def process_defend_attack
    puts "玩家防禦，敵方攻擊！"
    if enemy_set.ignore_defend_ok?
      ignore_list = [true,false]
    else
      ignore_list = [false,false]
    end
    diff = CardBattleManager.point_diff(*ignore_list)
    if diff < 0
      diff *= -1
      puts "敵人攻擊超越#{diff}點！"
      CardBattleManager.player_defend_failure
      CardBattleManager.enemy_attack_success(diff)
    else
      CardBattleManager.player_defend_success(diff)
      CardBattleManager.enemy_attack_blocked
    end

  end
  #--------------------------------------------------------------------------
  # ● 執行回合結果判斷
  #--------------------------------------------------------------------------
  def process_battle_judge
    puts "執行回合結果判斷"
    if CardBattleManager.e_cards.dead?
      # 玩家勝利，因敵方HP歸零
      puts "玩家勝利，因敵方HP歸零"
      CardBattleManager.process_win
    elsif CardBattleManager.p_cards.dead?
      # 玩家失敗，因玩家HP歸零
      puts "玩家失敗，因玩家HP歸零"
      CardBattleManager.process_loss(:hp)
    else 
      # 重新開始回合
      CardBattleManager.prepare_turn_restart
    end
  end
  #--------------------------------------------------------------------------
  # ● 執行玩家保留牌
  #--------------------------------------------------------------------------
  def process_player_reserve
    puts "玩家保留牌組..."
    #CardBattleManager.p_cards.process_reserve_cards
    #wait_for_ok
    @spriteset.clear_player_selected_card
    wait_for_effect
    @spriteset.start_input_reserve_for(CardBattleManager.p_cards)
    wait_for_input
    @spriteset.player_reserve
    wait_for_effect
    CardBattleManager.process_end_player_reserve
  end
  #--------------------------------------------------------------------------
  # ● 執行敵人保留牌
  #--------------------------------------------------------------------------
  def process_enemy_reserve
    puts "敵人保留牌組..."
    CardBattleManager.e_cards.process_reserve_cards
    @spriteset.enemy_reserve
    wait_for_effect
    CardBattleManager.process_end_enemy_reserve
  end
  #--------------------------------------------------------------------------
  # ● 執行回合重新開始
  #--------------------------------------------------------------------------
  def process_end_turn_restart
    puts "回合重新開始..."
    @spriteset.player_hide_battle_mode
    @spriteset.enemy_hide_battle_mode
    CardBattleManager.process_end_turn_restart
  end
  #--------------------------------------------------------------------------
  # ● 勝利處理
  #--------------------------------------------------------------------------
  def process_win
    puts "玩家勝利！"
    CardBattleManager.phase_battle_end
    SceneManager.call(Scene_BattleWin)
  end
  #--------------------------------------------------------------------------
  # ● 戰敗處理
  #--------------------------------------------------------------------------
  def process_loss
    puts "玩家戰敗..."
    SceneManager.call(Scene_BattleLose)
  end
  
  #--------------------------------------------------------------------------
  # ● 取得玩家卡牌組
  #--------------------------------------------------------------------------
  def player_set
    CardBattleManager.p_cards
  end
  #--------------------------------------------------------------------------
  # ● 取得敵方卡牌組
  #--------------------------------------------------------------------------
  def enemy_set
    CardBattleManager.e_cards
  end

end
end
