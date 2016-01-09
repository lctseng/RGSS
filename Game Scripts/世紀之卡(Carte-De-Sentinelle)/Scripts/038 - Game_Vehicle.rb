#encoding:utf-8
#==============================================================================
# ■ Game_Vehicle
#------------------------------------------------------------------------------
# 　管理載具的類。
#   在 Game_Map 類的內部使用。 如果當前地圖沒有載具，坐標設為(-1, -1)。
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :altitude                 # 高度（飛艇用）
  attr_reader   :driving                  # 駕駛中的標志
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #     type : 載具類型（:boat, :ship, :airship）
  #--------------------------------------------------------------------------
  def initialize(type)
    super()
    @type = type
    @altitude = 0
    @driving = false
    @direction = 4
    @walk_anime = false
    @step_anime = false
    @walking_bgm = nil
    init_move_speed
    load_system_settings
  end
  #--------------------------------------------------------------------------
  # ● 初始化移動速度
  #--------------------------------------------------------------------------
  def init_move_speed
    @move_speed = 4 if @type == :boat
    @move_speed = 5 if @type == :ship
    @move_speed = 6 if @type == :airship
  end
  #--------------------------------------------------------------------------
  # ● 獲取系統設置
  #--------------------------------------------------------------------------
  def system_vehicle
    return $data_system.boat    if @type == :boat
    return $data_system.ship    if @type == :ship
    return $data_system.airship if @type == :airship
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 讀取系統設置
  #--------------------------------------------------------------------------
  def load_system_settings
    @map_id           = system_vehicle.start_map_id
    @x                = system_vehicle.start_x
    @y                = system_vehicle.start_y
    @character_name   = system_vehicle.character_name
    @character_index  = system_vehicle.character_index
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if @driving
      @map_id = $game_map.map_id
      sync_with_player
    elsif @map_id == $game_map.map_id
      moveto(@x, @y)
    end
    if @type == :airship
      @priority_type = @driving ? 2 : 0
    else
      @priority_type = 1
    end
    @walk_anime = @step_anime = @driving
  end
  #--------------------------------------------------------------------------
  # ● 更改位置
  #--------------------------------------------------------------------------
  def set_location(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 判定坐標是否一致
  #--------------------------------------------------------------------------
  def pos?(x, y)
    @map_id == $game_map.map_id && super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● 判定是否透明
  #--------------------------------------------------------------------------
  def transparent
    @map_id != $game_map.map_id || super
  end
  #--------------------------------------------------------------------------
  # ● 上船／上車
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    @walk_anime = true
    @step_anime = true
    @walking_bgm = RPG::BGM.last
    system_vehicle.bgm.play
  end
  #--------------------------------------------------------------------------
  # ● 下船／下車
  #--------------------------------------------------------------------------
  def get_off
    @driving = false
    @walk_anime = false
    @step_anime = false
    @direction = 4
    @walking_bgm.play
  end
  #--------------------------------------------------------------------------
  # ● 與玩家同步
  #--------------------------------------------------------------------------
  def sync_with_player
    @x = $game_player.x
    @y = $game_player.y
    @real_x = $game_player.real_x
    @real_y = $game_player.real_y
    @direction = $game_player.direction
    update_bush_depth
  end
  #--------------------------------------------------------------------------
  # ● 獲取移動速度
  #--------------------------------------------------------------------------
  def speed
    @move_speed
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 Y 坐標
  #--------------------------------------------------------------------------
  def screen_y
    super - altitude
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以移動
  #--------------------------------------------------------------------------
  def movable?
    !moving? && !(@type == :airship && @altitude < max_altitude)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_airship_altitude if @type == :airship
  end
  #--------------------------------------------------------------------------
  # ● 更新飛艇的高度
  #--------------------------------------------------------------------------
  def update_airship_altitude
    if @driving
      @altitude += 1 if @altitude < max_altitude && takeoff_ok?
    elsif @altitude > 0
      @altitude -= 1
      @priority_type = 0 if @altitude == 0
    end
    @step_anime = (@altitude == max_altitude)
    @priority_type = 2 if @altitude > 0
  end
  #--------------------------------------------------------------------------
  # ● 獲取飛艇的飛行高度
  #--------------------------------------------------------------------------
  def max_altitude
    return 32
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以離岸／起飛
  #--------------------------------------------------------------------------
  def takeoff_ok?
    $game_player.followers.gather?
  end
  #--------------------------------------------------------------------------
  # ● 判定是否可以靠岸／著陸
  #     d : 方向（2,4,6,8）
  #--------------------------------------------------------------------------
  def land_ok?(x, y, d)
    if @type == :airship
      return false unless $game_map.airship_land_ok?(x, y)
      return false unless $game_map.events_xy(x, y).empty?
    else
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return false unless $game_map.passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
    end
    return true
  end
end
