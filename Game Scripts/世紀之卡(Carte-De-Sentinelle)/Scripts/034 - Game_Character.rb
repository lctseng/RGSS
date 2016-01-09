#encoding:utf-8
#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
#   添加了路徑移動的地圖人物類。
#   是 Game_Player、Game_Follower、GameVehicle、Game_Event 的父類。
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 常量
  #--------------------------------------------------------------------------
  ROUTE_END               = 0             # 移動路徑的終點
  ROUTE_MOVE_DOWN         = 1             # 向下移動
  ROUTE_MOVE_LEFT         = 2             # 向左移動
  ROUTE_MOVE_RIGHT        = 3             # 向右移動
  ROUTE_MOVE_UP           = 4             # 向上移動
  ROUTE_MOVE_LOWER_L      = 5             # 左下移動
  ROUTE_MOVE_LOWER_R      = 6             # 右下移動
  ROUTE_MOVE_UPPER_L      = 7             # 坐上移動
  ROUTE_MOVE_UPPER_R      = 8             # 右上移動
  ROUTE_MOVE_RANDOM       = 9             # 隨機移動
  ROUTE_MOVE_TOWARD       = 10            # 接近玩家
  ROUTE_MOVE_AWAY         = 11            # 遠離玩家
  ROUTE_MOVE_FORWARD      = 12            # 前進一步
  ROUTE_MOVE_BACKWARD     = 13            # 后退一步
  ROUTE_JUMP              = 14            # 跳躍
  ROUTE_WAIT              = 15            # 等待
  ROUTE_TURN_DOWN         = 16            # 臉朝向下
  ROUTE_TURN_LEFT         = 17            # 臉朝向左
  ROUTE_TURN_RIGHT        = 18            # 臉朝向右
  ROUTE_TURN_UP           = 19            # 臉朝向上
  ROUTE_TURN_90D_R        = 20            # 右轉 90 度
  ROUTE_TURN_90D_L        = 21            # 左轉 90 度
  ROUTE_TURN_180D         = 22            # 后轉180 度
  ROUTE_TURN_90D_R_L      = 23            # 隨機向左右轉
  ROUTE_TURN_RANDOM       = 24            # 隨機轉換方向
  ROUTE_TURN_TOWARD       = 25            # 朝向玩家
  ROUTE_TURN_AWAY         = 26            # 背向玩家
  ROUTE_SWITCH_ON         = 27            # 開啟開關
  ROUTE_SWITCH_OFF        = 28            # 關閉開關
  ROUTE_CHANGE_SPEED      = 29            # 更改移動速度
  ROUTE_CHANGE_FREQ       = 30            # 更改移動頻度
  ROUTE_WALK_ANIME_ON     = 31            # 開啟步行動畫
  ROUTE_WALK_ANIME_OFF    = 32            # 關閉步行動畫
  ROUTE_STEP_ANIME_ON     = 33            # 開啟踏步動畫
  ROUTE_STEP_ANIME_OFF    = 34            # 關閉踏步動畫
  ROUTE_DIR_FIX_ON        = 35            # 開啟固定朝向
  ROUTE_DIR_FIX_OFF       = 36            # 關閉固定朝向
  ROUTE_THROUGH_ON        = 37            # 開啟穿透
  ROUTE_THROUGH_OFF       = 38            # 關閉穿透
  ROUTE_TRANSPARENT_ON    = 39            # 開啟透明化
  ROUTE_TRANSPARENT_OFF   = 40            # 關閉透明化
  ROUTE_CHANGE_GRAPHIC    = 41            # 更改圖像
  ROUTE_CHANGE_OPACITY    = 42            # 更改不透明度
  ROUTE_CHANGE_BLENDING   = 43            # 更改合成方式
  ROUTE_PLAY_SE           = 44            # 播放聲效
  ROUTE_SCRIPT            = 45            # 腳本
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :move_route_forcing       # 移動路徑強制的標志
  #--------------------------------------------------------------------------
  # ● 初始化公有成員變量
  #--------------------------------------------------------------------------
  def init_public_members
    super
    @move_route_forcing = false
  end
  #--------------------------------------------------------------------------
  # ● 初始化私有成員變量
  #--------------------------------------------------------------------------
  def init_private_members
    super
    @move_route = nil                     # 移動路徑
    @move_route_index = 0                 # 移動路徑的執行位置
    @original_move_route = nil            # 原路徑
    @original_move_route_index = 0        # 原路徑的執行位置
    @wait_count = 0                       # 等待計數
  end
  #--------------------------------------------------------------------------
  # ● 記憶移動路徑
  #--------------------------------------------------------------------------
  def memorize_move_route
    @original_move_route        = @move_route
    @original_move_route_index  = @move_route_index
  end
  #--------------------------------------------------------------------------
  # ● 恢復移動路徑
  #--------------------------------------------------------------------------
  def restore_move_route
    @move_route           = @original_move_route
    @move_route_index     = @original_move_route_index
    @original_move_route  = nil
  end
  #--------------------------------------------------------------------------
  # ● 強制移動路徑
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    memorize_move_route unless @original_move_route
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新停止
  #--------------------------------------------------------------------------
  def update_stop
    super
    update_routine_move if @move_route_forcing
  end
  #--------------------------------------------------------------------------
  # ● 更新跟隨路徑的移動
  #--------------------------------------------------------------------------
  def update_routine_move
    if @wait_count > 0
      @wait_count -= 1
    else
      @move_succeed = true
      command = @move_route.list[@move_route_index]
      if command
        process_move_command(command)
        advance_move_route_index
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理移動指令
  #--------------------------------------------------------------------------
  def process_move_command(command)
    params = command.parameters
    case command.code
    when ROUTE_END;               process_route_end
    when ROUTE_MOVE_DOWN;         move_straight(2)
    when ROUTE_MOVE_LEFT;         move_straight(4)
    when ROUTE_MOVE_RIGHT;        move_straight(6)
    when ROUTE_MOVE_UP;           move_straight(8)
    when ROUTE_MOVE_LOWER_L;      move_diagonal(4, 2)
    when ROUTE_MOVE_LOWER_R;      move_diagonal(6, 2)
    when ROUTE_MOVE_UPPER_L;      move_diagonal(4, 8)
    when ROUTE_MOVE_UPPER_R;      move_diagonal(6, 8)
    when ROUTE_MOVE_RANDOM;       move_random
    when ROUTE_MOVE_TOWARD;       move_toward_player
    when ROUTE_MOVE_AWAY;         move_away_from_player
    when ROUTE_MOVE_FORWARD;      move_forward
    when ROUTE_MOVE_BACKWARD;     move_backward
    when ROUTE_JUMP;              jump(params[0], params[1])
    when ROUTE_WAIT;              @wait_count = params[0] - 1
    when ROUTE_TURN_DOWN;         set_direction(2)
    when ROUTE_TURN_LEFT;         set_direction(4)
    when ROUTE_TURN_RIGHT;        set_direction(6)
    when ROUTE_TURN_UP;           set_direction(8)
    when ROUTE_TURN_90D_R;        turn_right_90
    when ROUTE_TURN_90D_L;        turn_left_90
    when ROUTE_TURN_180D;         turn_180
    when ROUTE_TURN_90D_R_L;      turn_right_or_left_90
    when ROUTE_TURN_RANDOM;       turn_random
    when ROUTE_TURN_TOWARD;       turn_toward_player
    when ROUTE_TURN_AWAY;         turn_away_from_player
    when ROUTE_SWITCH_ON;         $game_switches[params[0]] = true
    when ROUTE_SWITCH_OFF;        $game_switches[params[0]] = false
    when ROUTE_CHANGE_SPEED;      @move_speed = params[0]
    when ROUTE_CHANGE_FREQ;       @move_frequency = params[0]
    when ROUTE_WALK_ANIME_ON;     @walk_anime = true
    when ROUTE_WALK_ANIME_OFF;    @walk_anime = false
    when ROUTE_STEP_ANIME_ON;     @step_anime = true
    when ROUTE_STEP_ANIME_OFF;    @step_anime = false
    when ROUTE_DIR_FIX_ON;        @direction_fix = true
    when ROUTE_DIR_FIX_OFF;       @direction_fix = false
    when ROUTE_THROUGH_ON;        @through = true
    when ROUTE_THROUGH_OFF;       @through = false
    when ROUTE_TRANSPARENT_ON;    @transparent = true
    when ROUTE_TRANSPARENT_OFF;   @transparent = false
    when ROUTE_CHANGE_GRAPHIC;    set_graphic(params[0], params[1])
    when ROUTE_CHANGE_OPACITY;    @opacity = params[0]
    when ROUTE_CHANGE_BLENDING;   @blend_type = params[0]
    when ROUTE_PLAY_SE;           params[0].play
    when ROUTE_SCRIPT;            eval(params[0])
    end
  end
  #--------------------------------------------------------------------------
  # ● 計算 X 方向的距離
  #--------------------------------------------------------------------------
  def distance_x_from(x)
    result = @x - x
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● 計算 Y 方向的距離
  #--------------------------------------------------------------------------
  def distance_y_from(y)
    result = @y - y
    if $game_map.loop_vertical? && result.abs > $game_map.height / 2
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● 隨機移動
  #--------------------------------------------------------------------------
  def move_random
    move_straight(2 + rand(4) * 2, false)
  end
  #--------------------------------------------------------------------------
  # ● 接近人物
  #--------------------------------------------------------------------------
  def move_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 4 : 6)
      move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 8 : 2)
      move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 遠離人物
  #--------------------------------------------------------------------------
  def move_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 6 : 4)
      move_straight(sy > 0 ? 2 : 8) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 2 : 8)
      move_straight(sx > 0 ? 6 : 4) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 朝向向人物
  #--------------------------------------------------------------------------
  def turn_toward_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 4 : 6)
    elsif sy != 0
      set_direction(sy > 0 ? 8 : 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 背向人物
  #--------------------------------------------------------------------------
  def turn_away_from_character(character)
    sx = distance_x_from(character.x)
    sy = distance_y_from(character.y)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 6 : 4)
    elsif sy != 0
      set_direction(sy > 0 ? 2 : 8)
    end
  end
  #--------------------------------------------------------------------------
  # ● 朝向玩家
  #--------------------------------------------------------------------------
  def turn_toward_player
    turn_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # ● 背向玩家
  #--------------------------------------------------------------------------
  def turn_away_from_player
    turn_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # ● 接近玩家
  #--------------------------------------------------------------------------
  def move_toward_player
    move_toward_character($game_player)
  end
  #--------------------------------------------------------------------------
  # ● 遠離玩家
  #--------------------------------------------------------------------------
  def move_away_from_player
    move_away_from_character($game_player)
  end
  #--------------------------------------------------------------------------
  # ● 前進一步
  #--------------------------------------------------------------------------
  def move_forward
    move_straight(@direction)
  end
  #--------------------------------------------------------------------------
  # ● 后退一步
  #--------------------------------------------------------------------------
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    move_straight(reverse_dir(@direction), false)
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 跳躍
  #     x_plus : X 坐標增加值
  #     y_plus : Y 坐標增加值
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  #--------------------------------------------------------------------------
  # ● 處理移動路徑的終點
  #--------------------------------------------------------------------------
  def process_route_end
    if @move_route.repeat
      @move_route_index = -1
    elsif @move_route_forcing
      @move_route_forcing = false
      restore_move_route
    end
  end
  #--------------------------------------------------------------------------
  # ● 推進移動路徑的執行位置
  #--------------------------------------------------------------------------
  def advance_move_route_index
    @move_route_index += 1 if @move_succeed || @move_route.skippable
  end
  #--------------------------------------------------------------------------
  # ● 右轉 90 度
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2;  set_direction(4)
    when 4;  set_direction(8)
    when 6;  set_direction(2)
    when 8;  set_direction(6)
    end
  end
  #--------------------------------------------------------------------------
  # ● 左轉 90 度
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2;  set_direction(6)
    when 4;  set_direction(2)
    when 6;  set_direction(8)
    when 8;  set_direction(4)
    end
  end
  #--------------------------------------------------------------------------
  # ● 后轉180 度
  #--------------------------------------------------------------------------
  def turn_180
    set_direction(reverse_dir(@direction))
  end
  #--------------------------------------------------------------------------
  # ● 隨機向左右轉
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    case rand(2)
    when 0;  turn_right_90
    when 1;  turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # ● 隨機轉換方向
  #--------------------------------------------------------------------------
  def turn_random
    set_direction(2 + rand(4) * 2)
  end
  #--------------------------------------------------------------------------
  # ● 交換人物位置
  #--------------------------------------------------------------------------
  def swap(character)
    new_x = character.x
    new_y = character.y
    character.moveto(x, y)
    moveto(new_x, new_y)
  end
end
