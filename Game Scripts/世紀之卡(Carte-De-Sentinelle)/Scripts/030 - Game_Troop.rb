#encoding:utf-8
#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　管理敵群和戰鬥相關資料的類，也可執行如戰鬥事件管理之類的功能。
#   本類的實例請參考 $game_troop 。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 敵人名字后綴的字表
  #--------------------------------------------------------------------------
  LETTER_TABLE = [' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',
                  ' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',
                  ' U',' V',' W',' X',' Y',' Z']
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # 戰鬥畫面的狀態
  attr_reader   :interpreter              # 戰鬥事件用事件解釋器
  attr_reader   :event_flags              # 戰鬥事件執行完成的標志
  attr_reader   :turn_count               # 回合數
  attr_reader   :name_counts              # 敵人名稱出現數的記錄 HASH
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    clear
  end
  #--------------------------------------------------------------------------
  # ● 獲取成員
  #--------------------------------------------------------------------------
  def members
    @enemies
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @names_count = {}
  end
  #--------------------------------------------------------------------------
  # ● 獲取敵群
  #--------------------------------------------------------------------------
  def troop
    $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # ● 設置
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hide if member.hidden
      enemy.screen_x = member.x
      enemy.screen_y = member.y
      @enemies.push(enemy)
    end
    init_screen_tone
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # ● 初始化畫面的色調
  #--------------------------------------------------------------------------
  def init_screen_tone
    @screen.start_tone_change($game_map.screen.tone, 0) if $game_map
  end
  #--------------------------------------------------------------------------
  # ● 同名的敵人附加字母后綴
  #--------------------------------------------------------------------------
  def make_unique_names
    members.each do |enemy|
      next unless enemy.alive?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name] || 0
      enemy.letter = LETTER_TABLE[n % LETTER_TABLE.size]
      @names_count[enemy.original_name] = n + 1
    end
    members.each do |enemy|
      n = @names_count[enemy.original_name] || 0
      enemy.plural = true if n >= 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    @screen.update
  end
  #--------------------------------------------------------------------------
  # ● 獲取敵人名字的數組
  #    戰鬥開始時的顯示用。除去重復的。
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    members.each do |enemy|
      next unless enemy.alive?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    names
  end
  #--------------------------------------------------------------------------
  # ● 判定戰鬥事件（頁）條件是否符合
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if !c.turn_ending && !c.turn_valid && !c.enemy_valid &&
       !c.actor_valid && !c.switch_valid
      return false      # 條件未設置…不執行
    end
    if @event_flags[page]
      return false      # 執行完成
    end
    if c.turn_ending    # 回合結束時
      return false unless BattleManager.turn_end?
    end
    if c.turn_valid     # 回合數
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 && n != a)
      return false if (b > 0 && (n < 1 || n < a || n % b != a % b))
    end
    if c.enemy_valid    # 敵人
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp_rate * 100 > c.enemy_hp
    end
    if c.actor_valid    # 角色
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp_rate * 100 > c.actor_hp
    end
    if c.switch_valid   # 開關
      return false if !$game_switches[c.switch_id]
    end
    return true         # 條件符合
  end
  #--------------------------------------------------------------------------
  # ● 設置戰鬥事件
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    return if @interpreter.setup_reserved_common_event
    troop.pages.each do |page|
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      @event_flags[page] = true if page.span <= 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加回合
  #--------------------------------------------------------------------------
  def increase_turn
    troop.pages.each {|page| @event_flags[page] = false if page.span == 1 }
    @turn_count += 1
  end
  #--------------------------------------------------------------------------
  # ● 計算經驗值的總數
  #--------------------------------------------------------------------------
  def exp_total
    dead_members.inject(0) {|r, enemy| r += enemy.exp }
  end
  #--------------------------------------------------------------------------
  # ● 計算金錢的總數
  #--------------------------------------------------------------------------
  def gold_total
    dead_members.inject(0) {|r, enemy| r += enemy.gold } * gold_rate
  end
  #--------------------------------------------------------------------------
  # ● 獲取金錢的倍率
  #--------------------------------------------------------------------------
  def gold_rate
    $game_party.gold_double? ? 2 : 1
  end
  #--------------------------------------------------------------------------
  # ● 生成物品數組
  #--------------------------------------------------------------------------
  def make_drop_items
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_items }
  end
end
