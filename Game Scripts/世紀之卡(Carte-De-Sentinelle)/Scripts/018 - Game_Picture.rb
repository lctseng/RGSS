#encoding:utf-8
#==============================================================================
# ■ Game_Picture
#------------------------------------------------------------------------------
# 　管理圖片的類。本類在 Game_Pictures 類的內部使用，當需要特定編號的圖片時才
#   生成實例。
#==============================================================================

class Game_Picture
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :number                   # 圖片編號
  attr_reader   :name                     # 文件名
  attr_reader   :origin                   # 原點
  attr_reader   :x                        # X 坐標
  attr_reader   :y                        # Y 坐標
  attr_reader   :zoom_x                   # X 方向縮放率
  attr_reader   :zoom_y                   # Y 方向縮放率
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :tone                     # 色調
  attr_reader   :angle                    # 旋轉角度
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(number)
    @number = number
    init_basic
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # ● 初始化基本變量
  #--------------------------------------------------------------------------
  def init_basic
    @name = ""
    @origin = @x = @y = 0
    @zoom_x = @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
  end
  #--------------------------------------------------------------------------
  # ● 初始化移動目標
  #--------------------------------------------------------------------------
  def init_target
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 初始化色調
  #--------------------------------------------------------------------------
  def init_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 初始化旋轉角度和速度
  #--------------------------------------------------------------------------
  def init_rotate
    @angle = 0
    @rotate_speed = 0
  end
  #--------------------------------------------------------------------------
  # ● 顯示圖片
  #--------------------------------------------------------------------------
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    init_target
    init_tone
    init_rotate
  end
  #--------------------------------------------------------------------------
  # ● 移動圖片
  #--------------------------------------------------------------------------
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end
  #--------------------------------------------------------------------------
  # ● 更改旋轉速度
  #--------------------------------------------------------------------------
  def rotate(speed)
    @rotate_speed = speed
  end
  #--------------------------------------------------------------------------
  # ● 開始更改色調
  #--------------------------------------------------------------------------
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    @tone = @tone_target.clone if @tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # ● 消除圖片
  #--------------------------------------------------------------------------
  def erase
    @name = ""
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    update_move
    update_tone_change
    update_rotate
  end
  #--------------------------------------------------------------------------
  # ● 更新圖片移動
  #--------------------------------------------------------------------------
  def update_move
    return if @duration == 0
    d = @duration
    @x = (@x * (d - 1) + @target_x) / d
    @y = (@y * (d - 1) + @target_y) / d
    @zoom_x  = (@zoom_x  * (d - 1) + @target_zoom_x)  / d
    @zoom_y  = (@zoom_y  * (d - 1) + @target_zoom_y)  / d
    @opacity = (@opacity * (d - 1) + @target_opacity) / d
    @duration -= 1
  end
  #--------------------------------------------------------------------------
  # ● 更新色調更改
  #--------------------------------------------------------------------------
  def update_tone_change
    return if @tone_duration == 0
    d = @tone_duration
    @tone.red   = (@tone.red   * (d - 1) + @tone_target.red)   / d
    @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
    @tone.blue  = (@tone.blue  * (d - 1) + @tone_target.blue)  / d
    @tone.gray  = (@tone.gray  * (d - 1) + @tone_target.gray)  / d
    @tone_duration -= 1
  end
  #--------------------------------------------------------------------------
  # ● 更新旋轉
  #--------------------------------------------------------------------------
  def update_rotate
    return if @rotate_speed == 0
    @angle += @rotate_speed / 2.0
    @angle += 360 while @angle < 0
    @angle %= 360
  end
end
