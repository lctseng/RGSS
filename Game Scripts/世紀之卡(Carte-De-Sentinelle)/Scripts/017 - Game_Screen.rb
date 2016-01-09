#encoding:utf-8
#==============================================================================
# ■ Game_Screen
#------------------------------------------------------------------------------
# 　更改色調以及畫面閃爍、保存畫面全體關系處理數據的類。
#   使用于 Game_Map 和 Game_Troop 類。
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :brightness               # 明亮度
  attr_reader   :tone                     # 色調
  attr_reader   :flash_color              # 閃爍顏色
  attr_reader   :pictures                 # 圖片
  attr_reader   :shake                    # 震動位置
  attr_reader   :weather_type             # 天氣 類型
  attr_reader   :weather_power            # 天氣 強度 (Float)
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @pictures = Game_Pictures.new
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    clear_fade
    clear_tone
    clear_flash
    clear_shake
    clear_weather
    clear_pictures
  end
  #--------------------------------------------------------------------------
  # ● 清除淡入・淡出效果
  #--------------------------------------------------------------------------
  def clear_fade
    @brightness = 255
    @fadeout_duration = 0
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 清除色調
  #--------------------------------------------------------------------------
  def clear_tone
    @tone = Tone.new
    @tone_target = Tone.new
    @tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 清除閃爍效果
  #--------------------------------------------------------------------------
  def clear_flash
    @flash_color = Color.new
    @flash_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 清除震動效果
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # ● 清除天氣
  #--------------------------------------------------------------------------
  def clear_weather
    @weather_type = :none
    @weather_power = 0
    @weather_power_target = 0
    @weather_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 清除圖片
  #--------------------------------------------------------------------------
  def clear_pictures
    @pictures.each {|picture| picture.erase }
  end
  #--------------------------------------------------------------------------
  # ● 開始淡出
  #--------------------------------------------------------------------------
  def start_fadeout(duration)
    @fadeout_duration = duration
    @fadein_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 開始淡入
  #--------------------------------------------------------------------------
  def start_fadein(duration)
    @fadein_duration = duration
    @fadeout_duration = 0
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
  # ● 開始閃爍
  #--------------------------------------------------------------------------
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  #--------------------------------------------------------------------------
  # ● 開始震動
  #     power : 強度
  #     speed : 速度
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # ● 更改天氣
  #     type  : 類型 (:none, :rain, :storm, :snow)
  #     power : 強度
  #    如果是下雨則顯示一陣一陣的雨點、沒有天氣類型 (:none) 的時候
  #    把 @weather_power_target (強度的目標值) 設置為 0 。
  #--------------------------------------------------------------------------
  def change_weather(type, power, duration)
    @weather_type = type if type != :none || duration == 0
    @weather_power_target = type == :none ? 0.0 : power.to_f
    @weather_duration = duration
    @weather_power = @weather_power_target if duration == 0
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    update_fadeout
    update_fadein
    update_tone
    update_flash
    update_shake
    update_weather
    update_pictures
  end
  #--------------------------------------------------------------------------
  # ● 更新淡出
  #--------------------------------------------------------------------------
  def update_fadeout
    if @fadeout_duration > 0
      d = @fadeout_duration
      @brightness = (@brightness * (d - 1)) / d
      @fadeout_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新淡入
  #--------------------------------------------------------------------------
  def update_fadein
    if @fadein_duration > 0
      d = @fadein_duration
      @brightness = (@brightness * (d - 1) + 255) / d
      @fadein_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新色調
  #--------------------------------------------------------------------------
  def update_tone
    if @tone_duration > 0
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新閃爍
  #--------------------------------------------------------------------------
  def update_flash
    if @flash_duration > 0
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新震動
  #--------------------------------------------------------------------------
  def update_shake
    if @shake_duration > 0 || @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 && @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      @shake_direction = -1 if @shake > @shake_power * 2
      @shake_direction = 1 if @shake < - @shake_power * 2
      @shake_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新天氣
  #--------------------------------------------------------------------------
  def update_weather
    if @weather_duration > 0
      d = @weather_duration
      @weather_power = (@weather_power * (d - 1) + @weather_power_target) / d
      @weather_duration -= 1
      if @weather_duration == 0 && @weather_power_target == 0
        @weather_type = :none
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新圖片
  #--------------------------------------------------------------------------
  def update_pictures
    @pictures.each {|picture| picture.update }
  end
  #--------------------------------------------------------------------------
  # ● 開始閃爍（慢性傷害和有害地形用）
  #--------------------------------------------------------------------------
  def start_flash_for_damage
    start_flash(Color.new(255,0,0,128), 8)
  end
end
