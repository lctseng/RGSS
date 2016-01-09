#encoding:utf-8
#==============================================================================
# ■ Sprite_UltSkill
#------------------------------------------------------------------------------
# 　施放必殺技的角色精靈
#==============================================================================
module CardBattle
class Sprite_UltSkill < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @battler = nil
    @picture_name = ''
    @fly_count = 0
    @fly_speed = 0
    @phase = :nil
    @skill_ext = nil
    @large_sprite = Sprite_UltLargeMap.new(viewport)
    @zoom_speed = 0.0
    @opacity_speed = 0
    @down_speed = 0
    @shadow_fly_speed = 0
    @shadow = []
    16.times do 
      @shadow.push(Sprite.new(viewport))
    end
    self.z += 10
    self.visible = false
    @half_width = Graphics.width / 2
    
  end
  #--------------------------------------------------------------------------
  # ● 設定角色必殺技圖片
  #--------------------------------------------------------------------------
  def set_ult_picture(filename)
    self.bitmap = Cache.picture(filename)
    
    @half_width = Graphics.width - self.width / 2
    
    
    @picture_name = filename
    self.zoom_x = self.zoom_y = 1.0
    self.opacity = 255
    
    self.x = self.width / -2
    self.ox = self.width / 2
    
    self.oy = self.height / 2
    self.y = Graphics.height - self.height + self.oy

    
    @shadow.each_with_index do |sprite,index|
      sprite.visible = true
      sprite.opacity = 255 - ( @shadow.size - index )*15 
      sprite.bitmap = self.bitmap
      sprite.x = ( sprite.width / -2 ) - ( @shadow.size - index )*50
      sprite.ox = sprite.width / 2
      sprite.oy = sprite.height / 2
      sprite.y = self.y
      sprite.z = self.z - 5
    end
    
    
    @fly_count = ULT_PICTURE_FLY_TIME
    @fly_speed =  ((Graphics.width + self.width ).to_f /  ULT_PICTURE_FLY_TIME / 1.8 ).ceil
    @shadow_fly_speed = @fly_speed 
    @zoom_speed = 3.0 / ULT_PICTURE_FLY_TIME
    @opacity_speed =( 255.0 / ULT_PICTURE_FLY_TIME).ceil
    @down_speed = (self.height.to_f * 0.5 / ULT_PICTURE_FLY_TIME).ceil
    @phase = :in
    self.visible = true
    change_skill_tone
    #$game_map.screen.start_shake(5, 5, 20)
    $game_map.screen.start_flash(Color.new(255,255,255),10)
    @large_sprite.fade_in
    
    
  end
  
  #--------------------------------------------------------------------------
  # ● 使用技能時的暗化特效
  #--------------------------------------------------------------------------
  def change_skill_tone
    night_tone = Tone.new
    night_tone.red = -68
    night_tone.green  = -68
    night_tone.blue = 0
    night_tone.gray = 68
    duration = 20
    @old_tone = $game_map.screen.tone.clone
    $game_map.screen.start_tone_change(night_tone, duration)
  end
  #--------------------------------------------------------------------------
  # ● 解除使用技能時的暗化特效
  #--------------------------------------------------------------------------
  def change_normal_tone
    duration = 20
    $game_map.screen.start_tone_change(@old_tone, duration)
  end
  #--------------------------------------------------------------------------
  # ● 取得真正檔名
  #--------------------------------------------------------------------------
  def real_file_name(pic_id)
    "Cut-in_#{pic_id}"
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    @shadow.each do |sprite|
      sprite.dispose
    end
    bitmap.dispose if bitmap
    @large_sprite.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    @large_sprite.update
    update_position
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中
  #--------------------------------------------------------------------------
  def effect?
    !end?
  end

  #--------------------------------------------------------------------------
  # ● 是否已經結束？
  #--------------------------------------------------------------------------
  def end?
    @phase == :end || @phase == :nil
  end
  #--------------------------------------------------------------------------
  # ● 更新影子的位置
  #--------------------------------------------------------------------------
  def update_shadow_pos
    @shadow.each_with_index do |sprite,index|
      if sprite.x >= self.x
        sprite.visible = false
      else
        sprite.x += @shadow_fly_speed
        if sprite.x > @half_width && sprite.width > 600
          sprite.x = @half_width
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 隱藏所有影子
  #--------------------------------------------------------------------------
  def hide_all_shadow
    @shadow.each do |sprite|
      sprite.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    if @fly_count > 0
      update_shadow_pos
      @fly_count -= 1
      case @phase
      when :in
        self.x += @fly_speed
        if self.x > @half_width && self.width > 600
          self.x = @half_width
        end
      when :out
        self.zoom_x += @zoom_speed
        self.zoom_y += @zoom_speed
        self.opacity -= @opacity_speed
        self.y += @down_speed
        #self.x += @fly_speed
      end
    else
      case @phase
      when :in
        @fly_count = ULT_PICTURE_STOP_TIME
        @phase = :stop
      when :stop
        update_shadow_pos
        @fly_count = ULT_PICTURE_FLY_OUT_TIME
        change_normal_tone
        @large_sprite.fade_out
        @phase = :out
      when :out
        self.visible = false
        @phase = :end
      end
    end
  end
end
end
