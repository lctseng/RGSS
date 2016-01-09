#encoding:utf-8
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解釋器。
#   本類在 Game_Map、Game_Troop、Game_Event 類的內部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :map_id             # 地圖 ID
  attr_reader   :event_id           # 事件 ID（僅指普通事件）
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #     depth : 堆置深度
  #--------------------------------------------------------------------------
  def initialize(depth = 0)
    @depth = depth
    check_overflow
    clear
  end
  #--------------------------------------------------------------------------
  # ● 檢查堆置是否過深
  #    普通情況下深度不允許超過 100 。
  #    更深的堆置可能會導致遞歸事件無限循環，所以直接引發退出錯誤。
  #--------------------------------------------------------------------------
  def check_overflow
    if @depth >= 100
      msgbox(Vocab::EventOverflow)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0
    @event_id = 0
    @list = nil                       # 執行內容
    @index = 0                        # 索引
    @branch = {}                      # 分歧數據
    @fiber = nil                      # 纖程
  end
  #--------------------------------------------------------------------------
  # ● 設置事件
  #--------------------------------------------------------------------------
  def setup(list, event_id = 0)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = list
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● 生成纖程
  #--------------------------------------------------------------------------
  def create_fiber
    @fiber = Fiber.new { run } if @list
  end
  #--------------------------------------------------------------------------
  # ● 儲存實例
  #    對纖程進行 Marshal 的自定義方法。
  #    此方法將事件的執行位置也一并保存起來。
  #--------------------------------------------------------------------------
  def marshal_dump
    [@depth, @map_id, @event_id, @list, @index + 1, @branch]
  end
  #--------------------------------------------------------------------------
  # ● 讀取實例
  #     obj : marshal_dump 中儲存的實例（數組）
  #    恢復多個數據（@depth、@map_id 等）的狀態，必要時重新創建纖程。
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch = obj
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● 判定當前地圖是否和事件啟動時的地圖相同
  #--------------------------------------------------------------------------
  def same_map?
    @map_id == $game_map.map_id
  end
  #--------------------------------------------------------------------------
  # ● 檢測／設置預定調用的公共事件
  #--------------------------------------------------------------------------
  def setup_reserved_common_event
    if $game_temp.common_event_reserved?
      setup($game_temp.reserved_common_event.list)
      $game_temp.clear_common_event
      true
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 執行
  #--------------------------------------------------------------------------
  def run
    wait_for_message
    while @list[@index] do
      execute_command
      @index += 1
    end
    Fiber.yield
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # ● 判定是否執行中
  #--------------------------------------------------------------------------
  def running?
    @fiber != nil
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    @fiber.resume if @fiber
  end
  #--------------------------------------------------------------------------
  # ● 迭代角色（ID）
  #     param : 大于 1 則返回 ID 指定的角色、0 則迭代全體角色
  #     注意：此方法和 iterate_actor_index(param) 的參數設置有所不同
  #--------------------------------------------------------------------------
  def iterate_actor_id(param)
    if param == 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_actors[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代隊員（可變）
  #     param1 : 0 則固定、1 則變量指定
  #     param2 : 角色 ID 或變量 ID 
  #--------------------------------------------------------------------------
  def iterate_actor_var(param1, param2)
    if param1 == 0
      iterate_actor_id(param2) {|actor| yield actor }
    else
      iterate_actor_id($game_variables[param2]) {|actor| yield actor }
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代隊員（索引）
  #     param : 0 則返回索引指定的隊員、 -1 則迭代全體隊員
  #--------------------------------------------------------------------------
  def iterate_actor_index(param)
    if param < 0
      $game_party.members.each {|actor| yield actor }
    else
      actor = $game_party.members[param]
      yield actor if actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代敵人（索引）
  #     param : 0 則返回索引指定的敵人、 -1 則迭代全體敵人
  #--------------------------------------------------------------------------
  def iterate_enemy_index(param)
    if param < 0
      $game_troop.members.each {|enemy| yield enemy }
    else
      enemy = $game_troop.members[param]
      yield enemy if enemy
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代戰鬥者（敵群全體、隊伍全體考慮）
  #     param1 : 0 則敵人、1 則角色
  #     param2 : 敵人的索引 或 角色的 ID
  #--------------------------------------------------------------------------
  def iterate_battler(param1, param2)
    if $game_party.in_battle
      if param1 == 0
        iterate_enemy_index(param2) {|enemy| yield enemy }
      else
        iterate_actor_id(param2) {|actor| yield actor }
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面系指令的對象
  #--------------------------------------------------------------------------
  def screen
    $game_party.in_battle ? $game_troop.screen : $game_map.screen
  end
  #--------------------------------------------------------------------------
  # ● 執行事件指令
  #--------------------------------------------------------------------------
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    method_name = "command_#{command.code}"
    send(method_name) if respond_to?(method_name)
  end
  #--------------------------------------------------------------------------
  # ● 跳過指令
  #    如果下一句事件指令的縮進比當前深的話，跳過當前指令。
  #--------------------------------------------------------------------------
  def command_skip
    @index += 1 while @list[@index + 1].indent > @indent
  end
  #--------------------------------------------------------------------------
  # ● 獲取下一句事件指令的代碼
  #--------------------------------------------------------------------------
  def next_event_code
    @list[@index + 1].code
  end
  #--------------------------------------------------------------------------
  # ● 獲取事件
  #     param : -1 則玩家、0 則本事件、其他 則是指定的事件ID 
  #--------------------------------------------------------------------------
  def get_character(param)
    if $game_party.in_battle
      nil
    elsif param < 0
      $game_player
    else
      events = same_map? ? $game_map.events : {}
      events[param > 0 ? param : @event_id]
    end
  end
  #--------------------------------------------------------------------------
  # ● 計算操作的數值
  #     operation    : 操作行為（0:增加 1:減少）
  #     operand_type : 操作類型（0:常量 1:變量）
  #     operand      : 操作數值（數值 或 變量 的 ID）
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    value = operand_type == 0 ? operand : $game_variables[operand]
    operation == 0 ? value : -value
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times { Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 等待顯示信息
  #--------------------------------------------------------------------------
  def wait_for_message
    Fiber.yield while $game_message.busy?
  end
  #--------------------------------------------------------------------------
  # ● 顯示文字
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    while next_event_code == 401       # 文字數據
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    case next_event_code
    when 102  # 顯示選項
      @index += 1 
      setup_choices(@list[@index].parameters)
    when 103  # 數值輸入的處理
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # 物品選擇的處理
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 顯示選項
  #--------------------------------------------------------------------------
  def command_102
    wait_for_message
    setup_choices(@params)
    Fiber.yield while $game_message.choice?
  end
  #--------------------------------------------------------------------------
  # ● 設置選項
  #--------------------------------------------------------------------------
  def setup_choices(params)
    params[0].each {|s| $game_message.choices.push(s) }
    $game_message.choice_cancel_type = params[1]
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● [**] 的時候
  #--------------------------------------------------------------------------
  def command_402
    command_skip if @branch[@indent] != @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 取消的時候
  #--------------------------------------------------------------------------
  def command_403
    command_skip if @branch[@indent] != 4
  end
  #--------------------------------------------------------------------------
  # ● 數值輸入的處理
  #--------------------------------------------------------------------------
  def command_103
    wait_for_message
    setup_num_input(@params)
    Fiber.yield while $game_message.num_input?
  end
  #--------------------------------------------------------------------------
  # ● 設置數值輸入
  #--------------------------------------------------------------------------
  def setup_num_input(params)
    $game_message.num_input_variable_id = params[0]
    $game_message.num_input_digits_max = params[1]
  end
  #--------------------------------------------------------------------------
  # ● 物品選擇的處理
  #--------------------------------------------------------------------------
  def command_104
    wait_for_message
    setup_item_choice(@params)
    Fiber.yield while $game_message.item_choice?
  end
  #--------------------------------------------------------------------------
  # ● 設置物品選擇
  #--------------------------------------------------------------------------
  def setup_item_choice(params)
    $game_message.item_choice_variable_id = params[0]
  end
  #--------------------------------------------------------------------------
  # ● 顯示滾動文字
  #--------------------------------------------------------------------------
  def command_105
    Fiber.yield while $game_message.visible
    $game_message.scroll_mode = true
    $game_message.scroll_speed = @params[0]
    $game_message.scroll_no_fast = @params[1]
    while next_event_code == 405
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● 添加注釋
  #--------------------------------------------------------------------------
  def command_108
    @comments = [@params[0]]
    while next_event_code == 408
      @index += 1
      @comments.push(@list[@index].parameters[0])
    end
  end
  #--------------------------------------------------------------------------
  # ● 條件分歧
  #--------------------------------------------------------------------------
  def command_111
    result = false
    case @params[0]
    when 0  # 開關
      result = ($game_switches[@params[1]] == (@params[2] == 0))
    when 1  # 變量
      value1 = $game_variables[@params[1]]
      if @params[2] == 0
        value2 = @params[3]
      else
        value2 = $game_variables[@params[3]]
      end
      case @params[4]
      when 0  # 等于
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 大于
        result = (value1 > value2)
      when 4  # 小于
        result = (value1 < value2)
      when 5  # 不等于
        result = (value1 != value2)
      end
    when 2  # 獨立開關
      if @event_id > 0
        key = [@map_id, @event_id, @params[1]]
        result = ($game_self_switches[key] == (@params[2] == 0))
      end
    when 3  # 計時器
      if $game_timer.working?
        if @params[2] == 0
          result = ($game_timer.sec >= @params[1])
        else
          result = ($game_timer.sec <= @params[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@params[1]]
      if actor
        case @params[2]
        when 0  # 在隊伍時
          result = ($game_party.members.include?(actor))
        when 1  # 名字
          result = (actor.name == @params[3])
        when 2  # 職業
          result = (actor.class_id == @params[3])
        when 3  # 技能
          result = (actor.skill_learn?($data_skills[@params[3]]))
        when 4  # 武器
          result = (actor.weapons.include?($data_weapons[@params[3]]))
        when 5  # 護甲
          result = (actor.armors.include?($data_armors[@params[3]]))
        when 6  # 狀態
          result = (actor.state?(@params[3]))
        end
      end
    when 5  # 敵人
      enemy = $game_troop.members[@params[1]]
      if enemy
        case @params[2]
        when 0  # 出現
          result = (enemy.alive?)
        when 1  # 狀態
          result = (enemy.state?(@params[3]))
        end
      end
    when 6  # 事件
      character = get_character(@params[1])
      if character
        result = (character.direction == @params[2])
      end
    when 7  # 金錢
      case @params[2]
      when 0  # 以上
        result = ($game_party.gold >= @params[1])
      when 1  # 以下
        result = ($game_party.gold <= @params[1])
      when 2  # 低于
        result = ($game_party.gold < @params[1])
      end
    when 8   # 物品
      result = $game_party.has_item?($data_items[@params[1]])
    when 9   # 武器
      result = $game_party.has_item?($data_weapons[@params[1]], @params[2])
    when 10  # 護甲
      result = $game_party.has_item?($data_armors[@params[1]], @params[2])
    when 11  # 按下按鈕
      result = Input.press?(@params[1])
    when 12  # 腳本
      result = eval(@params[1])
    when 13  # 載具
      result = ($game_player.vehicle == $game_map.vehicles[@params[1]])
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
  #--------------------------------------------------------------------------
  # ● 除此之外
  #--------------------------------------------------------------------------
  def command_411
    command_skip if @branch[@indent]
  end
  #--------------------------------------------------------------------------
  # ● 循環
  #--------------------------------------------------------------------------
  def command_112
  end
  #--------------------------------------------------------------------------
  # ● 重復
  #--------------------------------------------------------------------------
  def command_413
    begin
      @index -= 1
    end until @list[@index].indent == @indent
  end
  #--------------------------------------------------------------------------
  # ● 跳出循環
  #--------------------------------------------------------------------------
  def command_113
    loop do
      @index += 1
      return if @index >= @list.size - 1
      return if @list[@index].code == 413 && @list[@index].indent < @indent
    end
  end
  #--------------------------------------------------------------------------
  # ● 中止事件處理
  #--------------------------------------------------------------------------
  def command_115
    @index = @list.size
  end
  #--------------------------------------------------------------------------
  # ● 公共事件
  #--------------------------------------------------------------------------
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Game_Interpreter.new(@depth + 1)
      child.setup(common_event.list, same_map? ? @event_id : 0)
      child.run
    end
  end
  #--------------------------------------------------------------------------
  # ● 添加標簽
  #--------------------------------------------------------------------------
  def command_118
  end
  #--------------------------------------------------------------------------
  # ● 轉至標簽
  #--------------------------------------------------------------------------
  def command_119
    label_name = @params[0]
    @list.size.times do |i|
      if @list[i].code == 118 && @list[i].parameters[0] == label_name
        @index = i
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作開關
  #--------------------------------------------------------------------------
  def command_121
    (@params[0]..@params[1]).each do |i|
      $game_switches[i] = (@params[2] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 變量操作
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # 操作方式
    when 0  # 常量
      value = @params[4]
    when 1  # 變量
      value = $game_variables[@params[4]]
    when 2  # 隨機數
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # 游戲數據
      value = game_data_operand(@params[4], @params[5], @params[6])
    when 4  # 腳本
      value = eval(@params[4])
    end
    (@params[0]..@params[1]).each do |i|
      operate_variable(i, @params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取變量操作用的游戲數據
  #--------------------------------------------------------------------------
  def game_data_operand(type, param1, param2)
    case type
    when 0  # 物品
      return $game_party.item_number($data_items[param1])
    when 1  # 武器
      return $game_party.item_number($data_weapons[param1])
    when 2  # 護甲
      return $game_party.item_number($data_armors[param1])
    when 3  # 角色
      actor = $game_actors[param1]
      if actor
        case param2
        when 0      # 等級
          return actor.level
        when 1      # 經驗值
          return actor.exp
        when 2      # HP
          return actor.hp
        when 3      # MP
          return actor.mp
        when 4..11  # 普通能力值
          return actor.param(param2 - 4)
        end
      end
    when 4  # 敵人
      enemy = $game_troop.members[param1]
      if enemy
        case param2
        when 0      # HP
          return enemy.hp
        when 1      # MP
          return enemy.mp
        when 2..9   # 普通能力值
          return enemy.param(param2 - 2)
        end
      end
    when 5  # 地圖人物
      character = get_character(param1)
      if character
        case param2
        when 0  # X 坐標
          return character.x
        when 1  # Y 坐標
          return character.y
        when 2  # 方向
          return character.direction
        when 3  # 畫面 X 坐標
          return character.screen_x
        when 4  # 畫面 Y 坐標
          return character.screen_y
        end
      end
    when 6  # 隊伍
      actor = $game_party.members[param1]
      return actor ? actor.id : 0
    when 7  # 其他
      case param1
      when 0  # 地圖 ID
        return $game_map.map_id
      when 1  # 隊伍人數
        return $game_party.members.size
      when 2  # 金錢
        return $game_party.gold
      when 3  # 步數
        return $game_party.steps
      when 4  # 游戲時間
        return Graphics.frame_count / Graphics.frame_rate
      when 5  # 計時器
        return $game_timer.sec
      when 6  # 存檔回數
        return $game_system.save_count
      when 7  # 戰鬥回數
        return $game_system.battle_count
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 操作變量
  #--------------------------------------------------------------------------
  def operate_variable(variable_id, operation_type, value)
    begin
      case operation_type
      when 0  # 代入
        $game_variables[variable_id] = value
      when 1  # 加法
        $game_variables[variable_id] += value
      when 2  # 減法
        $game_variables[variable_id] -= value
      when 3  # 乘法
        $game_variables[variable_id] *= value
      when 4  # 除法
        $game_variables[variable_id] /= value
      when 5  # 取余
        $game_variables[variable_id] %= value
      end
    rescue
      $game_variables[variable_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作獨立開關
  #--------------------------------------------------------------------------
  def command_123
    if @event_id > 0
      key = [@map_id, @event_id, @params[0]]
      $game_self_switches[key] = (@params[1] == 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作計時器
  #--------------------------------------------------------------------------
  def command_124
    if @params[0] == 0  # 開始
      $game_timer.start(@params[1] * Graphics.frame_rate)
    else                # 停止
      $game_timer.stop
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減持有金錢
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@params[0], @params[1], @params[2])
    $game_party.gain_gold(value)
  end
  #--------------------------------------------------------------------------
  # ● 增減物品
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_items[@params[0]], value)
  end
  #--------------------------------------------------------------------------
  # ● 增減武器
  #--------------------------------------------------------------------------
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 增減護甲
  #--------------------------------------------------------------------------
  def command_128
    value = operate_value(@params[1], @params[2], @params[3])
    $game_party.gain_item($data_armors[@params[0]], value, @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 隊伍管理
  #--------------------------------------------------------------------------
  def command_129
    actor = $game_actors[@params[0]]
    if actor
      if @params[1] == 0    # 入隊
        if @params[2] == 1  # 初始化
          $game_actors[@params[0]].setup(@params[0])
        end
        $game_party.add_actor(@params[0])
      else                  # 離隊
        $game_party.remove_actor(@params[0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改戰鬥 BGM 
  #--------------------------------------------------------------------------
  def command_132
    $game_system.battle_bgm = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 更改戰鬥結束 ME 
  #--------------------------------------------------------------------------
  def command_133
    $game_system.battle_end_me = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 設置禁用存檔
  #--------------------------------------------------------------------------
  def command_134
    $game_system.save_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 設置禁用菜單
  #--------------------------------------------------------------------------
  def command_135
    $game_system.menu_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 設置禁用遇敵
  #--------------------------------------------------------------------------
  def command_136
    $game_system.encounter_disabled = (@params[0] == 0)
    $game_player.make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 設置禁用整隊
  #--------------------------------------------------------------------------
  def command_137
    $game_system.formation_disabled = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 更改窗口色調
  #--------------------------------------------------------------------------
  def command_138
    $game_system.window_tone = @params[0]
  end
  #--------------------------------------------------------------------------
  # ● 場所移動
  #--------------------------------------------------------------------------
  def command_201
    return if $game_party.in_battle
    Fiber.yield while $game_player.transfer? || $game_message.visible
    if @params[0] == 0                      # 直接指定
      map_id = @params[1]
      x = @params[2]
      y = @params[3]
    else                                    # 變量指定
      map_id = $game_variables[@params[1]]
      x = $game_variables[@params[2]]
      y = $game_variables[@params[3]]
    end
    $game_player.reserve_transfer(map_id, x, y, @params[4])
    $game_temp.fade_type = @params[5]
    Fiber.yield while $game_player.transfer?
  end
  #--------------------------------------------------------------------------
  # ● 設置載具位置
  #--------------------------------------------------------------------------
  def command_202
    if @params[1] == 0                      # 直接指定
      map_id = @params[2]
      x = @params[3]
      y = @params[4]
    else                                    # 變量指定
      map_id = $game_variables[@params[2]]
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_location(map_id, x, y) if vehicle
  end
  #--------------------------------------------------------------------------
  # ● 設置事件的位置
  #--------------------------------------------------------------------------
  def command_203
    character = get_character(@params[0])
    if character
      if @params[1] == 0                      # 直接指定
        character.moveto(@params[2], @params[3])
      elsif @params[1] == 1                   # 變量指定
        new_x = $game_variables[@params[2]]
        new_y = $game_variables[@params[3]]
        character.moveto(new_x, new_y)
      else                                    # 與其他事件交換
        character2 = get_character(@params[2])
        character.swap(character2) if character2
      end
      character.set_direction(@params[4]) if @params[4] > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 地圖卷動
  #--------------------------------------------------------------------------
  def command_204
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    $game_map.start_scroll(@params[0], @params[1], @params[2])
  end
  #--------------------------------------------------------------------------
  # ● 設置移動路徑
  #--------------------------------------------------------------------------
  def command_205
    $game_map.refresh if $game_map.need_refresh
    character = get_character(@params[0])
    if character
      character.force_move_route(@params[1])
      Fiber.yield while character.move_route_forcing if @params[1].wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 載具的乘降
  #--------------------------------------------------------------------------
  def command_206
    $game_player.get_on_off_vehicle
  end
  #--------------------------------------------------------------------------
  # ● 更改透明狀態
  #--------------------------------------------------------------------------
  def command_211
    $game_player.transparent = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 顯示動畫
  #--------------------------------------------------------------------------
  def command_212
    character = get_character(@params[0])
    if character
      character.animation_id = @params[1]
      Fiber.yield while character.animation_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示心情圖標
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character
      character.balloon_id = @params[1]
      Fiber.yield while character.balloon_id > 0 if @params[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 暫時消除事件
  #--------------------------------------------------------------------------
  def command_214
    $game_map.events[@event_id].erase if same_map? && @event_id > 0
  end
  #--------------------------------------------------------------------------
  # ● 更改隊列前進
  #--------------------------------------------------------------------------
  def command_216
    $game_player.followers.visible = (@params[0] == 0)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 集合隊伍成員
  #--------------------------------------------------------------------------
  def command_217
    return if $game_party.in_battle
    $game_player.followers.gather
    Fiber.yield until $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # ● 淡出畫面
  #--------------------------------------------------------------------------
  def command_221
    Fiber.yield while $game_message.visible
    screen.start_fadeout(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # ● 淡入畫面
  #--------------------------------------------------------------------------
  def command_222
    Fiber.yield while $game_message.visible
    screen.start_fadein(30)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # ● 更改畫面的色調
  #--------------------------------------------------------------------------
  def command_223
    screen.start_tone_change(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 畫面閃爍
  #--------------------------------------------------------------------------
  def command_224
    screen.start_flash(@params[0], @params[1])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 畫面震動
  #--------------------------------------------------------------------------
  def command_225
    screen.start_shake(@params[0], @params[1], @params[2])
    wait(@params[1]) if @params[2]
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def command_230
    wait(@params[0])
  end
  #--------------------------------------------------------------------------
  # ● 顯示圖片
  #--------------------------------------------------------------------------
  def command_231
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 變量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].show(@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end
  #--------------------------------------------------------------------------
  # ● 移動圖片
  #--------------------------------------------------------------------------
  def command_232
    if @params[3] == 0    # 直接指定
      x = @params[4]
      y = @params[5]
    else                  # 變量指定
      x = $game_variables[@params[4]]
      y = $game_variables[@params[5]]
    end
    screen.pictures[@params[0]].move(@params[2], x, y, @params[6],
      @params[7], @params[8], @params[9], @params[10])
    wait(@params[10]) if @params[11]
  end
  #--------------------------------------------------------------------------
  # ● 旋轉圖片
  #--------------------------------------------------------------------------
  def command_233
    screen.pictures[@params[0]].rotate(@params[1])
  end
  #--------------------------------------------------------------------------
  # ● 更改圖片的色調
  #--------------------------------------------------------------------------
  def command_234
    screen.pictures[@params[0]].start_tone_change(@params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # ● 消除圖片
  #--------------------------------------------------------------------------
  def command_235
    screen.pictures[@params[0]].erase
  end
  #--------------------------------------------------------------------------
  # ● 設置天氣
  #--------------------------------------------------------------------------
  def command_236
    return if $game_party.in_battle
    screen.change_weather(@params[0], @params[1], @params[2])
    wait(@params[2]) if @params[3]
  end
  #--------------------------------------------------------------------------
  # ● 播放 BGM 
  #--------------------------------------------------------------------------
  def command_241
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 淡出 BGM 
  #--------------------------------------------------------------------------
  def command_242
    RPG::BGM.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 記憶 BGM 
  #--------------------------------------------------------------------------
  def command_243
    $game_system.save_bgm
  end
  #--------------------------------------------------------------------------
  # ● 恢復 BGM 
  #--------------------------------------------------------------------------
  def command_244
    $game_system.replay_bgm
  end
  #--------------------------------------------------------------------------
  # ● 播放 BGS 
  #--------------------------------------------------------------------------
  def command_245
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 淡出 BGS 
  #--------------------------------------------------------------------------
  def command_246
    RPG::BGS.fade(@params[0] * 1000)
  end
  #--------------------------------------------------------------------------
  # ● 播放 ME 
  #--------------------------------------------------------------------------
  def command_249
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 播放 SE 
  #--------------------------------------------------------------------------
  def command_250
    @params[0].play
  end
  #--------------------------------------------------------------------------
  # ● 停止 SE 
  #--------------------------------------------------------------------------
  def command_251
    RPG::SE.stop
  end
  #--------------------------------------------------------------------------
  # ● 播放影像
  #--------------------------------------------------------------------------
  def command_261
    Fiber.yield while $game_message.visible
    Fiber.yield
    name = @params[0]
    Graphics.play_movie('Movies/' + name) unless name.empty?
  end
  #--------------------------------------------------------------------------
  # ● 更改地圖名稱顯示
  #--------------------------------------------------------------------------
  def command_281
    $game_map.name_display = (@params[0] == 0)
  end
  #--------------------------------------------------------------------------
  # ● 更改圖塊組
  #--------------------------------------------------------------------------
  def command_282
    $game_map.change_tileset(@params[0])
  end
  #--------------------------------------------------------------------------
  # ● 更改戰場背景
  #--------------------------------------------------------------------------
  def command_283
    $game_map.change_battleback(@params[0], @params[1])
  end
  #--------------------------------------------------------------------------
  # ● 更改遠景
  #--------------------------------------------------------------------------
  def command_284
    $game_map.change_parallax(@params[0], @params[1], @params[2],
                              @params[3], @params[4])
  end
  #--------------------------------------------------------------------------
  # ● 獲取指定位置的信息
  #--------------------------------------------------------------------------
  def command_285
    if @params[2] == 0      # 直接指定
      x = @params[3]
      y = @params[4]
    else                    # 變量指定
      x = $game_variables[@params[3]]
      y = $game_variables[@params[4]]
    end
    case @params[1]
    when 0      # 地形標志
      value = $game_map.terrain_tag(x, y)
    when 1      # 事件 ID
      value = $game_map.event_id_xy(x, y)
    when 2..4   # 圖塊 ID
      value = $game_map.tile_id(x, y, @params[1] - 2)
    else        # 區域 ID
      value = $game_map.region_id(x, y)
    end
    $game_variables[@params[0]] = value
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥的處理
  #--------------------------------------------------------------------------
  def command_301
    return if $game_party.in_battle
    if @params[0] == 0                      # 直接指定
      troop_id = @params[1]
    elsif @params[0] == 1                   # 變量指定
      troop_id = $game_variables[@params[1]]
    else                                    # 地圖指定的敵群
      troop_id = $game_player.make_encounter_troop_id
    end
    if $data_troops[troop_id]
      BattleManager.setup(troop_id, @params[2], @params[3])
      BattleManager.event_proc = Proc.new {|n| @branch[@indent] = n }
      $game_player.make_encounter_count
      SceneManager.call(Scene_Battle)
    end
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 勝利的時候
  #--------------------------------------------------------------------------
  def command_601
    command_skip if @branch[@indent] != 0
  end
  #--------------------------------------------------------------------------
  # ● 撤退的時候
  #--------------------------------------------------------------------------
  def command_602
    command_skip if @branch[@indent] != 1
  end
  #--------------------------------------------------------------------------
  # ● 全滅的時候
  #--------------------------------------------------------------------------
  def command_603
    command_skip if @branch[@indent] != 2
  end
  #--------------------------------------------------------------------------
  # ● 商店的處理
  #--------------------------------------------------------------------------
  def command_302
    return if $game_party.in_battle
    goods = [@params]
    while next_event_code == 605
      @index += 1
      goods.push(@list[@index].parameters)
    end
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, @params[4])
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 名字輸入的處理
  #--------------------------------------------------------------------------
  def command_303
    return if $game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_Name)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減 HP 
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      next if actor.dead?
      actor.change_hp(value, @params[5])
      actor.perform_collapse_effect if actor.dead?
    end
    SceneManager.goto(Scene_Gameover) if $game_party.all_dead?
  end
  #--------------------------------------------------------------------------
  # ● 增減 MP 
  #--------------------------------------------------------------------------
  def command_312
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改狀態
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor_var(@params[0], @params[1]) do |actor|
      already_dead = actor.dead?
      if @params[2] == 0
        actor.add_state(@params[3])
      else
        actor.remove_state(@params[3])
      end
      actor.perform_collapse_effect if actor.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # ● 完全恢復
  #--------------------------------------------------------------------------
  def command_314
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減經驗值
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_exp(actor.exp + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減等級
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_level(actor.level + value, @params[5])
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減能力值
  #--------------------------------------------------------------------------
  def command_317
    value = operate_value(@params[3], @params[4], @params[5])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.add_param(@params[2], value)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減技能
  #--------------------------------------------------------------------------
  def command_318
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
      else
        actor.forget_skill(@params[3])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更換裝備
  #--------------------------------------------------------------------------
  def command_319
    actor = $game_actors[@params[0]]
    actor.change_equip_by_id(@params[1], @params[2]) if actor
  end
  #--------------------------------------------------------------------------
  # ● 更改名字
  #--------------------------------------------------------------------------
  def command_320
    actor = $game_actors[@params[0]]
    actor.name = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # ● 更改職業
  #--------------------------------------------------------------------------
  def command_321
    actor = $game_actors[@params[0]]
    actor.change_class(@params[1]) if actor && $data_classes[@params[1]]
  end
  #--------------------------------------------------------------------------
  # ● 更改角色圖像
  #--------------------------------------------------------------------------
  def command_322
    actor = $game_actors[@params[0]]
    if actor
      actor.set_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 更改載具的圖像
  #--------------------------------------------------------------------------
  def command_323
    vehicle = $game_map.vehicles[@params[0]]
    vehicle.set_graphic(@params[1], @params[2]) if vehicle
  end
  #--------------------------------------------------------------------------
  # ● 更改稱號
  #--------------------------------------------------------------------------
  def command_324
    actor = $game_actors[@params[0]]
    actor.nickname = @params[1] if actor
  end
  #--------------------------------------------------------------------------
  # ● 增減敵人的 HP 
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      return if enemy.dead?
      enemy.change_hp(value, @params[4])
      enemy.perform_collapse_effect if enemy.dead?
    end
  end
  #--------------------------------------------------------------------------
  # ● 增減敵人的 MP 
  #--------------------------------------------------------------------------
  def command_332
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.mp += value
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改敵人的狀態
  #--------------------------------------------------------------------------
  def command_333
    iterate_enemy_index(@params[0]) do |enemy|
      already_dead = enemy.dead?
      if @params[1] == 0
        enemy.add_state(@params[2])
      else
        enemy.remove_state(@params[2])
      end
      enemy.perform_collapse_effect if enemy.dead? && !already_dead
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵人完全恢復
  #--------------------------------------------------------------------------
  def command_334
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.recover_all
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵人出現
  #--------------------------------------------------------------------------
  def command_335
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.appear
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵人變身
  #--------------------------------------------------------------------------
  def command_336
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.transform(@params[1])
      $game_troop.make_unique_names
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示戰鬥動畫
  #--------------------------------------------------------------------------
  def command_337
    iterate_enemy_index(@params[0]) do |enemy|
      enemy.animation_id = @params[1] if enemy.alive?
    end
  end
  #--------------------------------------------------------------------------
  # ● 強制戰鬥行動
  #--------------------------------------------------------------------------
  def command_339
    iterate_battler(@params[0], @params[1]) do |battler|
      next if battler.death_state?
      battler.force_action(@params[2], @params[3])
      BattleManager.force_action(battler)
      Fiber.yield while BattleManager.action_forced?
    end
  end
  #--------------------------------------------------------------------------
  # ● 中止戰鬥
  #--------------------------------------------------------------------------
  def command_340
    BattleManager.abort
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 打開菜單畫面
  #--------------------------------------------------------------------------
  def command_351
    return if $game_party.in_battle
    SceneManager.call(Scene_Menu)
    Window_MenuCommand::init_command_position
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 打開存檔畫面
  #--------------------------------------------------------------------------
  def command_352
    return if $game_party.in_battle
    SceneManager.call(Scene_Save)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 游戲結束
  #--------------------------------------------------------------------------
  def command_353
    SceneManager.goto(Scene_Gameover)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 返回標題畫面
  #--------------------------------------------------------------------------
  def command_354
    SceneManager.goto(Scene_Title)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # ● 腳本
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    eval(script)
  end
end
