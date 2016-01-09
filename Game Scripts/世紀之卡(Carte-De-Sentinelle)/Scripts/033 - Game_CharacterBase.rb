#encoding:utf-8
#==============================================================================
# ■ Game_CharacterBase
#------------------------------------------------------------------------------
# 　管理地圖人物的基本類。是所有地圖人物類的共通父類。擁有坐標、圖片等基本信息。
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # 地圖 X 坐標（理論坐標）
  attr_reader   :y                        # 地圖 Y 坐標（理論坐標）
  attr_reader   :real_x                   # 地圖 X 坐標（實際坐標）
  attr_reader   :real_y                   # 地圖 Y 坐標（實際坐標）
  attr_reader   :tile_id                  # 圖塊 ID（0 則無效）
  attr_reader   :character_name           # 行走圖文件名
  attr_reader   :character_index          # 行走圖索引
  attr_reader   :move_speed               # 移動速度
  attr_reader   :move_frequency           # 移動頻度
  attr_reader   :walk_anime               # 步行動畫
  attr_reader   :step_anime               # 踏步動畫
  attr_reader   :direction_fix            # 固定朝向
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 方向
  attr_reader   :pattern                  # 圖案
  attr_reader   :priority_type            # 優先級類型
  attr_reader   :through                  # 穿透
  attr_reader   :bush_depth               # 草木深度
  attr_accessor :animation_id             # 動畫 ID
  attr_accessor :balloon_id               # 心情圖標 ID
  attr_accessor :transparent              # 透明狀態
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    init_public_members
    init_private_members
  end
  #--------------------------------------------------------------------------
  # ● 初始化公有成員變量
  #--------------------------------------------------------------------------
  def init_public_members
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_index = 0
    @move_speed = 4
    @move_frequency = 6
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 1
    @priority_type = 1
    @through = false
    @bush_depth = 0
    @animation_id = 0
    @balloon_id = 0
    @transparent = false
  end
  #--------------------------------------------------------------------------
  # ● 初始化私有成員變量
  #--------------------------------------------------------------------------
  def init_private_members
    @original_direction = 2               # 原方向
    @original_pattern = 1                 # 原圖案
    @anime_count = 0                      # 動畫計數
    @stop_count = 0                       # 停止計數
    @jump_count = 0                       # 跳躍計數
    @jump_peak = 0                        # 跳躍的頂點計數
    @locked = false                       # 鎖的標志
    @prelock_direction = 0                # 被鎖上前的方向
    @move_succeed = true                  # 移動成功的標志
  end
  #--------------------------------------------------------------------------
  # ● 坐標一致判定
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @x == x && @y == y
  end
  #--------------------------------------------------------------------------
  # ● 判定 坐標是否一致 與“穿透是否關閉”（nt = No Through）
  #--------------------------------------------------------------------------
  def pos_nt?(x, y)
    pos?(x, y) && !@through
  end
  #--------------------------------------------------------------------------
  # ● 判定優先級“與人物同層”
  #--------------------------------------------------------------------------
  def normal_priority?
    @priority_type == 1
  end
  #--------------------------------------------------------------------------
  # ● 判定是否移動中
  #--------------------------------------------------------------------------
  def moving?
    @real_x != @x || @real_y != @y
  end
  #--------------------------------------------------------------------------
  # ● 判定是否跳躍中
  #--------------------------------------------------------------------------
  def jumping?
    @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 計算跳躍的高度
  #--------------------------------------------------------------------------
  def jump_height
    (@jump_peak * @jump_peak - (@jump_count - @jump_peak).abs ** 2) / 2
  end
  #--------------------------------------------------------------------------
  # ● 判定是否停止
  #--------------------------------------------------------------------------
  def stopping?
    !moving? && !jumping?
  end
  #--------------------------------------------------------------------------
  # ● 獲取移動速度（判斷是否跑步）
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + (dash? ? 1 : 0)
  end
  #--------------------------------------------------------------------------
  # ● 計算一幀內移動的距離
  #--------------------------------------------------------------------------
  def distance_per_frame
    2 ** real_move_speed / 256.0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否跑步狀態
  #--------------------------------------------------------------------------
  def dash?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判定是否調試時穿透狀態
  #--------------------------------------------------------------------------
  def debug_through?
    return false
  end
  #--------------------------------------------------------------------------
  # ● 矯正姿勢
  #--------------------------------------------------------------------------
  def straighten
    @pattern = 1 if @walk_anime || @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取反方向
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  def reverse_dir(d)
    return 10 - d
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以通行（檢查 地圖的通行度 和 前方是否有路障）
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false unless $game_map.valid?(x2, y2)
    return true if @through || debug_through?
    return false unless map_passable?(x, y, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_characters?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以斜向通行
  #     horz : 橫向（4 or 6）
  #     vert : 縱向（2 or 8）
  #--------------------------------------------------------------------------
  def diagonal_passable?(x, y, horz, vert)
    x2 = $game_map.round_x_with_direction(x, horz)
    y2 = $game_map.round_y_with_direction(y, vert)
    (passable?(x, y, vert) && passable?(x, y2, horz)) ||
    (passable?(x, y, horz) && passable?(x2, y, vert))
  end
  #--------------------------------------------------------------------------
  # ● 判定地圖是否可以通行
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    $game_map.passable?(x, y, d)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否與玩家人物碰撞
  #--------------------------------------------------------------------------
  def collide_with_characters?(x, y)
    collide_with_events?(x, y) || collide_with_vehicles?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否與事件碰撞
  #--------------------------------------------------------------------------
  def collide_with_events?(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否與載具碰撞
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    $game_map.boat.pos_nt?(x, y) || $game_map.ship.pos_nt?(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 移動到指定位置
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x
    @real_y = @y
    @prelock_direction = 0
    straighten
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # ● 更改方向
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  def set_direction(d)
    @direction = d if !@direction_fix && d != 0
    @stop_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否圖塊
  #--------------------------------------------------------------------------
  def tile?
    @tile_id > 0 && @priority_type == 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否地圖人物的實例
  #--------------------------------------------------------------------------
  def object_character?
    @tile_id > 0 || @character_name[0, 1] == '!'
  end
  #--------------------------------------------------------------------------
  # ● 獲取偏移的坐標量
  #--------------------------------------------------------------------------
  def shift_y
    object_character? ? 0 : 4
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 X 坐標
  #--------------------------------------------------------------------------
  def screen_x
    $game_map.adjust_x(@real_x) * 32 + 16
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 Y 坐標
  #--------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@real_y) * 32 + 32 - shift_y - jump_height
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 Z 坐標
  #--------------------------------------------------------------------------
  def screen_z
    @priority_type * 100
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    update_animation
    return update_jump if jumping?
    return update_move if moving?
    return update_stop
  end
  #--------------------------------------------------------------------------
  # ● 更新跳躍
  #--------------------------------------------------------------------------
  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x) / (@jump_count + 1.0)
    @real_y = (@real_y * @jump_count + @y) / (@jump_count + 1.0)
    update_bush_depth
    if @jump_count == 0
      @real_x = @x = $game_map.round_x(@x)
      @real_y = @y = $game_map.round_y(@y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新移動
  #--------------------------------------------------------------------------
  def update_move
    @real_x = [@real_x - distance_per_frame, @x].max if @x < @real_x
    @real_x = [@real_x + distance_per_frame, @x].min if @x > @real_x
    @real_y = [@real_y - distance_per_frame, @y].max if @y < @real_y
    @real_y = [@real_y + distance_per_frame, @y].min if @y > @real_y
    update_bush_depth unless moving?
  end
  #--------------------------------------------------------------------------
  # ● 更新停止
  #--------------------------------------------------------------------------
  def update_stop
    @stop_count += 1 unless @locked
  end
  #--------------------------------------------------------------------------
  # ● 更新步行／踏步動畫
  #--------------------------------------------------------------------------
  def update_animation
    update_anime_count
    if @anime_count > 18 - real_move_speed * 2
      update_anime_pattern
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新動畫計數
  #--------------------------------------------------------------------------
  def update_anime_count
    if moving? && @walk_anime
      @anime_count += 1.5
    elsif @step_anime || @pattern != @original_pattern
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新動畫圖案
  #--------------------------------------------------------------------------
  def update_anime_pattern
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % 4
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否梯子
  #--------------------------------------------------------------------------
  def ladder?
    $game_map.ladder?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # ● 更新草木深度
  #--------------------------------------------------------------------------
  def update_bush_depth
    if normal_priority? && !object_character? && bush? && !jumping?
      @bush_depth = 8 unless moving?
    else
      @bush_depth = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否草木茂密處
  #--------------------------------------------------------------------------
  def bush?
    $game_map.bush?(@x, @y)
  end
  #--------------------------------------------------------------------------
  # ● 獲取地形標志
  #--------------------------------------------------------------------------
  def terrain_tag
    $game_map.terrain_tag(@x, @y)
  end
  #--------------------------------------------------------------------------
  # ● 獲取區域 ID 
  #--------------------------------------------------------------------------
  def region_id
    $game_map.region_id(@x, @y)
  end
  #--------------------------------------------------------------------------
  # ● 增加步數
  #--------------------------------------------------------------------------
  def increase_steps
    set_direction(8) if ladder?
    @stop_count = 0
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # ● 更改圖像
  #     character_name  : 新的行走圖文件名
  #     character_index : 新的行走圖索引
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index)
    @tile_id = 0
    @character_name = character_name
    @character_index = character_index
    @original_pattern = 1
  end
  #--------------------------------------------------------------------------
  # ● 判定面前的事件是否被啟動
  #--------------------------------------------------------------------------
  def check_event_trigger_touch_front
    x2 = $game_map.round_x_with_direction(@x, @direction)
    y2 = $game_map.round_y_with_direction(@y, @direction)
    check_event_trigger_touch(x2, y2)
  end
  #--------------------------------------------------------------------------
  # ● 接觸事件的啟動判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 徑向移動
  #     d       : 方向（2,4,6,8）
  #     turn_ok : 是否可以改變方向
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@x, @y, d)
    if @move_succeed
      set_direction(d)
      @x = $game_map.round_x_with_direction(@x, d)
      @y = $game_map.round_y_with_direction(@y, d)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(d))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(d))
      increase_steps
    elsif turn_ok
      set_direction(d)
      check_event_trigger_touch_front
    end
  end
  #--------------------------------------------------------------------------
  # ● 斜向移動
  #     horz : 橫向（4 or 6）
  #     vert : 縱向（2 or 8）
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(x, y, horz, vert)
    if @move_succeed
      @x = $game_map.round_x_with_direction(@x, horz)
      @y = $game_map.round_y_with_direction(@y, vert)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(horz))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    end
    set_direction(horz) if @direction == reverse_dir(horz)
    set_direction(vert) if @direction == reverse_dir(vert)
  end
end
