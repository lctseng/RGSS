#encoding:utf-8
#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戰鬥過程管理器。
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● 設置
  #--------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    init_members
    $game_troop.setup(troop_id)
    @can_escape = can_escape
    @can_lose = can_lose
    make_escape_ratio
  end
  #--------------------------------------------------------------------------
  # ● 初始化成員
  #--------------------------------------------------------------------------
  def self.init_members
    @phase = :init              # 戰鬥階段
    @can_escape = false         # 允許逃走的標誌
    @can_lose = false           # 允許全滅的標誌
    @event_proc = nil           # 事件用回調
    @preemptive = false         # 先制攻擊的標誌
    @surprise = false           # 被偷襲的標誌
    @actor_index = -1           # 指令輸入中的角色
    @action_forced = nil        # 強制的戰鬥行動
    @map_bgm = nil              # 戰鬥前的 BGM（記憶用）
    @map_bgs = nil              # 戰鬥前的 BGS（記憶用）
    @action_battlers = []       # 行動順序列表
  end
  #--------------------------------------------------------------------------
  # ● 遇敵時的處理
  #--------------------------------------------------------------------------
  def self.on_encounter
    @preemptive = (rand < rate_preemptive)
    @surprise = (rand < rate_surprise && !@preemptive)
  end
  #--------------------------------------------------------------------------
  # ● 獲取先制攻擊的幾率
  #--------------------------------------------------------------------------
  def self.rate_preemptive
    $game_party.rate_preemptive($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 獲取被偷襲的幾率
  #--------------------------------------------------------------------------
  def self.rate_surprise
    $game_party.rate_surprise($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # ● 保存 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # ● 播放戰鬥 BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # ● 播放戰鬥結束 ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    $game_system.battle_end_me.play
  end
  #--------------------------------------------------------------------------
  # ● 重播 BGM 和 BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @map_bgm.replay unless $BTEST
    @map_bgs.replay unless $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 生成撤退成功率
  #--------------------------------------------------------------------------
  def self.make_escape_ratio
    @escape_ratio = 1.5 - 1.0 * $game_troop.agi / $game_party.agi
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合執行中
  #--------------------------------------------------------------------------
  def self.in_turn?
    @phase == :turn
  end
  #--------------------------------------------------------------------------
  # ● 判定是否回合結束
  #--------------------------------------------------------------------------
  def self.turn_end?
    @phase == :turn_end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否中止戰鬥
  #--------------------------------------------------------------------------
  def self.aborting?
    @phase == :aborting
  end
  #--------------------------------------------------------------------------
  # ● 獲取是否允許逃走
  
  #--------------------------------------------------------------------------
  def self.can_escape?
    @can_escape
  end
  #--------------------------------------------------------------------------
  # ● 獲取指令輸入中的角色
  #--------------------------------------------------------------------------
  def self.actor
    @actor_index >= 0 ? $game_party.members[@actor_index] : nil
  end
  #--------------------------------------------------------------------------
  # ● 清除指令輸入中的角色
  #--------------------------------------------------------------------------
  def self.clear_actor
    @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 進行下一個指令輸入
  #--------------------------------------------------------------------------
  def self.next_command
    begin
      if !actor || !actor.next_command
        @actor_index += 1
        return false if @actor_index >= $game_party.members.size
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 返回上一個指令輸入
  #--------------------------------------------------------------------------
  def self.prior_command
    begin
      if !actor || !actor.prior_command
        @actor_index -= 1
        return false if @actor_index < 0
      end
    end until actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 設置返回事件的回調用 Proc
  #--------------------------------------------------------------------------
  def self.event_proc=(proc)
    @event_proc = proc
  end
  #--------------------------------------------------------------------------
  # ● 設置等待用方法
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # ● 等待信息顯示的結束
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @method_wait_for_message.call if @method_wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥開始
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab::Emerge, name))
    end
    if @preemptive
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 中鬥戰鬥
  #--------------------------------------------------------------------------
  def self.abort
    @phase = :aborting
  end
  #--------------------------------------------------------------------------
  # ● 判定勝敗
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if $game_party.members.empty?
      return process_defeat  if $game_party.all_dead?
      return process_victory if $game_troop.all_dead?
      return process_abort   if aborting?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 勝利時的處理
  #--------------------------------------------------------------------------
  def self.process_victory
    play_battle_end_me
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 逃走時的處理
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      process_abort
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # ● 中止時的處理
  #--------------------------------------------------------------------------
  def self.process_abort
    replay_bgm_and_bgs
    SceneManager.return
    battle_end(1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 全滅時的處理
  #--------------------------------------------------------------------------
  def self.process_defeat
    $game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    wait_for_message
    if @can_lose
      revive_battle_members
      replay_bgm_and_bgs
      SceneManager.return
    else
      SceneManager.goto(Scene_Gameover)
    end
    battle_end(2)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 復活參戰角色（全滅時）
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    $game_party.battle_members.each do |actor|
      actor.hp = 1 if actor.dead?
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥結束
  #     result : 結果（0:勝利 1:逃走 2:全滅）
  #--------------------------------------------------------------------------
  def self.battle_end(result)
    @phase = nil
    @event_proc.call(result) if @event_proc
    $game_party.on_battle_end
    $game_troop.on_battle_end
    SceneManager.exit if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 開始輸入指令
  #--------------------------------------------------------------------------
  def self.input_start
    if @phase != :input
      @phase = :input
      $game_party.make_actions
      $game_troop.make_actions
      clear_actor
    end
    return !@surprise && $game_party.inputable?
  end
  #--------------------------------------------------------------------------
  # ● 回合開始
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    clear_actor
    $game_troop.increase_turn
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # ● 回合結束
  #--------------------------------------------------------------------------
  def self.turn_end
    @phase = :turn_end
    @preemptive = false
    @surprise = false
  end
  #--------------------------------------------------------------------------
  # ● 顯示獲得的經驗值
  #--------------------------------------------------------------------------
  def self.display_exp
    if $game_troop.exp_total > 0
      text = sprintf(Vocab::ObtainExp, $game_troop.exp_total)
      $game_message.add('\.' + text)
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示獲得的金錢
  #--------------------------------------------------------------------------
  def self.gain_gold
    if $game_troop.gold_total > 0
      text = sprintf(Vocab::ObtainGold, $game_troop.gold_total)
      $game_message.add('\.' + text)
      $game_party.gain_gold($game_troop.gold_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 顯示獲得的物品
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 顯示獲得經驗值和等級上升
  #--------------------------------------------------------------------------
  def self.gain_exp
    $game_party.all_members.each do |actor|
      actor.gain_exp($game_troop.exp_total)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 生成行動順序
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += $game_party.members unless @surprise
    @action_battlers += $game_troop.members unless @preemptive
    @action_battlers.each {|battler| battler.make_speed }
    @action_battlers.sort! {|a,b| b.speed - a.speed }
  end
  #--------------------------------------------------------------------------
  # ● 強制行動
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @action_forced = battler
    @action_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰鬥行動的強制狀態
  #--------------------------------------------------------------------------
  def self.action_forced?
    @action_forced != nil
  end
  #--------------------------------------------------------------------------
  # ● 獲取強制行動的戰鬥者
  #--------------------------------------------------------------------------
  def self.action_forced_battler
    @action_forced
  end
  #--------------------------------------------------------------------------
  # ● 清除強制的戰鬥行動
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil
  end
  #--------------------------------------------------------------------------
  # ● 獲取下一個行動角色
  #    獲取處于行動順序列表頂端的戰鬥者。
  #    沒有獲取角色時（index 為 nil, 或者戰鬥事件在戰鬥后發生）則跳過此行動。
  #--------------------------------------------------------------------------
  def self.next_subject
    loop do
      battler = @action_battlers.shift
      return nil unless battler
      next unless battler.index && battler.alive?
      return battler
    end
  end
end
