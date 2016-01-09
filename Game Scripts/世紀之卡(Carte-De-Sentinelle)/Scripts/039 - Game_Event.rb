#encoding:utf-8
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　處理事件的類。擁有條件判斷、事件頁的切換、并行處理、執行事件等功能。
#   在 Game_Map 類的內部使用。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # 啟動方式
  attr_reader   :list                     # 執行內容
  attr_reader   :starting                 # 啟動中的標志
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #     event : RPG::Event
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 初始化公有成員變量
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @trigger = 0
    @list = nil
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 初始化私有成員變量
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_type = 0                        # 移動類型
    @erased = false                       # 暫時消除的標志
    @page = nil                           # 事件頁
  end
  #--------------------------------------------------------------------------
  # ● 判定是否與人物碰撞
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    super || collide_with_player_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否與玩家碰撞（包括跟隨角色）
  #--------------------------------------------------------------------------
  def collide_with_player_characters?(x, y)
    normal_priority? && $game_player.collide?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 鎖定（立即停止執行中的事件）
  #--------------------------------------------------------------------------
  def lock
    unless @locked
      @prelock_direction = @direction
      turn_toward_player
      @locked = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 解鎖
  #--------------------------------------------------------------------------
  def unlock
    if @locked
      @locked = false
      set_direction(@prelock_direction)
    end
  end
  #--------------------------------------------------------------------------
  # ● 停止時的更新
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_self_movement unless @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # ● 自動移動的更新
  #--------------------------------------------------------------------------
  def update_self_movement
    if near_the_screen? && @stop_count > stop_count_threshold
      case @move_type
      when 1;  move_type_random
      when 2;  move_type_toward_player
      when 3;  move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否在畫面的可視區域內
  #     dx : 從畫面中央開始計算，左右有多少個圖塊。
  #     dy : 從畫面中央開始計算，上下有多少個圖塊。
  #--------------------------------------------------------------------------
  def near_the_screen?(dx = 12, dy = 8)
    ax = $game_map.adjust_x(@real_x) - Graphics.width / 2 / 32
    ay = $game_map.adjust_y(@real_y) - Graphics.height / 2 / 32
    ax >= -dx && ax <= dx && ay >= -dy && ay <= dy
  end
  #--------------------------------------------------------------------------
  # ● 計算自動移動時停止計數最低值
  #--------------------------------------------------------------------------
  def stop_count_threshold
    30 * (5 - @move_frequency)
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 隨機
  #--------------------------------------------------------------------------
  def move_type_random
    case rand(6)
    when 0..1;  move_random
    when 2..4;  move_forward
    when 5;     @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 接近
  #--------------------------------------------------------------------------
  def move_type_toward_player
    if near_the_player?
      case rand(6)
      when 0..3;  move_toward_player
      when 4;     move_random
      when 5;     move_forward
      end
    else
      move_random
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定事件是否臨近玩家
  #--------------------------------------------------------------------------
  def near_the_player?
    sx = distance_x_from($game_player.x).abs
    sy = distance_y_from($game_player.y).abs
    sx + sy < 20
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 自定義
  #--------------------------------------------------------------------------
  def move_type_custom
    update_routine_move
  end
  #--------------------------------------------------------------------------
  # ● 清除啟動中的標志
  #--------------------------------------------------------------------------
  def clear_starting_flag
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 判定執行內容是否為空
  #--------------------------------------------------------------------------
  def empty?
    !@list || @list.size <= 1
  end
  #--------------------------------------------------------------------------
  # ● 判定指定的啟動方式是否能啟動事件
  #     triggers : 啟動方式的數組
  #--------------------------------------------------------------------------
  def trigger_in?(triggers)
    triggers.include?(@trigger)
  end
  #--------------------------------------------------------------------------
  # ● 事件啟動
  #--------------------------------------------------------------------------
  def start
    return if empty?
    @starting = true
    lock if trigger_in?([0,1,2])
  end
  #--------------------------------------------------------------------------
  # ● 暫時消除
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    new_page = @erased ? nil : find_proper_page
    setup_page(new_page) if !new_page || new_page != @page
  end
  #--------------------------------------------------------------------------
  # ● 尋找條件符合的事件頁
  #--------------------------------------------------------------------------
  def find_proper_page
    @event.pages.reverse.find {|page| conditions_met?(page) }
  end
  #--------------------------------------------------------------------------
  # ● 判定事件頁的條件是否符合
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if c.switch1_valid
      return false unless $game_switches[c.switch1_id]
    end
    if c.switch2_valid
      return false unless $game_switches[c.switch2_id]
    end
    if c.variable_valid
      return false if $game_variables[c.variable_id] < c.variable_value
    end
    if c.self_switch_valid
      key = [@map_id, @event.id, c.self_switch_ch]
      return false if $game_self_switches[key] != true
    end
    if c.item_valid
      item = $data_items[c.item_id]
      return false unless $game_party.has_item?(item)
    end
    if c.actor_valid
      actor = $game_actors[c.actor_id]
      return false unless $game_party.members.include?(actor)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 設置事件頁
  #--------------------------------------------------------------------------
  def setup_page(new_page)
    @page = new_page
    if @page
      setup_page_settings
    else
      clear_page_settings
    end
    update_bush_depth
    clear_starting_flag
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● 清除事件頁的設置
  #--------------------------------------------------------------------------
  def clear_page_settings
    @tile_id          = 0
    @character_name   = ""
    @character_index  = 0
    @move_type        = 0
    @through          = true
    @trigger          = nil
    @list             = nil
    @interpreter      = nil
  end
  #--------------------------------------------------------------------------
  # ● 設置事件頁的設置
  #--------------------------------------------------------------------------
  def setup_page_settings
    @tile_id          = @page.graphic.tile_id
    @character_name   = @page.graphic.character_name
    @character_index  = @page.graphic.character_index
    if @original_direction != @page.graphic.direction
      @direction          = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction  = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern            = @page.graphic.pattern
      @original_pattern   = @pattern
    end
    @move_type          = @page.move_type
    @move_speed         = @page.move_speed
    @move_frequency     = @page.move_frequency
    @move_route         = @page.move_route
    @move_route_index   = 0
    @move_route_forcing = false
    @walk_anime         = @page.walk_anime
    @step_anime         = @page.step_anime
    @direction_fix      = @page.direction_fix
    @through            = @page.through
    @priority_type      = @page.priority_type
    @trigger            = @page.trigger
    @list               = @page.list
    @interpreter = @trigger == 4 ? Game_Interpreter.new : nil
  end
  #--------------------------------------------------------------------------
  # ● 接觸事件的啟動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && $game_player.pos?(x, y)
      start if !jumping? && normal_priority?
    end
  end
  #--------------------------------------------------------------------------
  # ● 自動事件的啟動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    start if @trigger == 3
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
end
