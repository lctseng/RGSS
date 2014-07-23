#encoding:utf-8

=begin
*******************************************************************************************

   ＊ Lctseng - 系統設定畫面 ＊

                       for RGSS3

        Ver 1.01   2013.09.02

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、設定BGM(ME)、SE(BGS)、亮度的大小
                       二、具有"重置"功能

   更新紀錄：
    Ver 1.00 ：
    日期：2013.08.18
    摘要：一、最初版本


   更新紀錄：
    Ver 1.01 ：
    日期：2013.09.02
    摘要：一、新增重置功能，允許調整各圖示的位置

    

    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.Scene_Base
                          2.Audio
                          
                          
                          二、此腳本新定義以下類別和模組：
                          1.Lctseng::SystemOption
                          2.Game_SystemOption
                          3.Scene_SystemOption
                          4.Spriteset_OptionBar
                          5.Sprite_OptionArrow
                          

*******************************************************************************************

=end

#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************

#--------------------------------------------------------------------------
# ★ 紀錄腳本資訊
#--------------------------------------------------------------------------
if !$lctseng_scripts  
  $lctseng_scripts = {}
end
$lctseng_scripts[:system_option] = "1.01"

puts "載入腳本：Lctseng - 系統設定畫面，版本：#{$lctseng_scripts[:system_option]}"
  
#encoding:utf-8
#==============================================================================
# ■ Lctseng::SystemOption
#------------------------------------------------------------------------------
# 　有關系統設定選單的設定
#==============================================================================
module Lctseng
module SystemOption
  #--------------------------------------------------------------------------
  # ● 顯示條的寬高，配合圖片填寫
  #--------------------------------------------------------------------------
  Bar_Width = 290
  Bar_Height = 43
  #--------------------------------------------------------------------------
  # ● 顯示條的X座標(全部統一)
  #--------------------------------------------------------------------------
  Bar_X = 236
  #--------------------------------------------------------------------------
  # ● 顯示條的Y座標(三個分開)
  #--------------------------------------------------------------------------
  Bar_Y = [101,193,296]
  #--------------------------------------------------------------------------
  # ● 箭頭的X座標(全部統一)
  #--------------------------------------------------------------------------
  ARROW_X = 47
  #--------------------------------------------------------------------------
  # ● 箭頭的Y座標(四個分開)
  #--------------------------------------------------------------------------
  ARROW_Y = [99,205,308,384]
  
end
end



#encoding:utf-8
#==============================================================================
# ■ Audio
#------------------------------------------------------------------------------
# 　內建的聲音模組
#==============================================================================
module Audio
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  class << self
  unless @lctseng_for_system_option_on_Audio_alias
    alias lctseng_for_system_option_on_Audio_for_Bgm_play bgm_play # 播放背景音樂
    alias lctseng_for_system_option_on_Audio_for_me_play me_play # 播放音樂
    alias lctseng_for_system_option_on_Audio_for_Bgs_play bgs_play # 播放背景音效
    alias lctseng_for_system_option_on_Audio_for_se_play se_play # 播放音效
    @lctseng_for_system_option_on_Audio_alias = true
  end
  end
  #--------------------------------------------------------------------------
  # ● 設定聲音的大小比率(百分比)
  #--------------------------------------------------------------------------
  def self.set_sound_rate(rate)
    @sound_rate = rate / 100.0
  end
  #--------------------------------------------------------------------------
  # ● 設定音樂的大小比率(百分比)
  #--------------------------------------------------------------------------
  def self.set_music_rate(rate)
    @music_rate = rate / 100.0
  end
  #--------------------------------------------------------------------------
  # ● 設定聲音的大小比率(百分比)，含效果
  #--------------------------------------------------------------------------
  def self.set_sound_rate_with_effect(rate)
    old_rate = @sound_rate
    old_music = RPG::BGS.last.clone
    #puts "原比率：#{old_rate}"
    old_music.volume =  (old_music.volume / old_rate).round
    #puts "原音量：#{old_music.volume}"
    RPG::BGS.stop
    set_sound_rate(rate)
    old_music.volume *= @sound_rate
    old_music.volume = 100 if old_music.volume > 100
    puts "位置：#{old_music.pos}"
    old_music.replay
    ##
    name = 'SoundOptionEffect'
    se_play('Audio/SE/' + name)
  end
  #--------------------------------------------------------------------------
  # ● 設定音樂的大小比率(百分比)，含效果
  #--------------------------------------------------------------------------
  def self.set_music_rate_with_effect(rate)
    old_rate = @music_rate
    old_music = RPG::BGM.last.clone
    #puts "原比率：#{old_rate}"
    old_music.volume =  (old_music.volume / old_rate).round
    #puts "原音量：#{old_music.volume}"
    RPG::BGM.stop
    set_music_rate(rate)
    old_music.volume *= @music_rate
    old_music.volume = 100 if old_music.volume > 100
    puts "位置：#{old_music.pos}"
    old_music.pos += 60000
    old_music.replay
  end  
  #--------------------------------------------------------------------------
  # ● 播放背景音樂
  #--------------------------------------------------------------------------
  def self.bgm_play(filename,volume = 100,pitch = 100,pos = 0)
    if !@music_rate
      @music_rate = 1.0
    end
    volume = (volume * @music_rate).round 
    lctseng_for_system_option_on_Audio_for_Bgm_play(filename,volume,pitch,pos)
  end
  #--------------------------------------------------------------------------
  # ● 播放音樂
  #--------------------------------------------------------------------------
  def self.me_play(filename,volume = 100,pitch = 100)
    if !@music_rate
      @music_rate = 1.0
    end
    volume = (volume * @music_rate).round 
    lctseng_for_system_option_on_Audio_for_me_play(filename,volume,pitch)
  end
  #--------------------------------------------------------------------------
  # ● 播放背景音效
  #--------------------------------------------------------------------------
  def self.bgs_play(filename,volume = 80,pitch = 100,pos = 0)
    if !@sound_rate
      @sound_rate = 1.0
    end
    volume = (volume * @sound_rate).round 
    lctseng_for_system_option_on_Audio_for_Bgs_play(filename,volume,pitch,pos)
  end
  #--------------------------------------------------------------------------
  # ● 播放音效
  #--------------------------------------------------------------------------
  def self.se_play(filename,volume = 80,pitch = 100)
    if !@sound_rate
      @sound_rate = 1.0
    end
    volume = (volume * @sound_rate).round 
    lctseng_for_system_option_on_Audio_for_se_play(filename,volume,pitch)
  end  
end


#encoding:utf-8
#==============================================================================
# ■Game_SystemOption
#------------------------------------------------------------------------------
# 　管理系統資訊的視窗
#==============================================================================
class Game_SystemOption
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :volume_music
  attr_accessor :volume_sound
  attr_accessor :brightness
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    clear_all_data
  end
  #--------------------------------------------------------------------------
  # ● 重置
  #--------------------------------------------------------------------------
  def reset
    puts "執行重置"
    clear_all_data
  end
  #--------------------------------------------------------------------------
  # ● 取得三大資料的陣列型態
  #--------------------------------------------------------------------------
  def data_array
    [@volume_music,@volume_sound,@brightness]
  end
  #--------------------------------------------------------------------------
  # ● 取得三大資料的比率資訊
  #--------------------------------------------------------------------------
  def data_rates
    [@volume_music/100.0,@volume_sound/100.0,@brightness/455.0]
  end
  #--------------------------------------------------------------------------
  # ● 清除所有資料
  #--------------------------------------------------------------------------
  def clear_all_data
    @volume_music = 100
    @volume_sound = 100
    @brightness = 255
  end
  #--------------------------------------------------------------------------
  # ● 改變音效音量(單位畫格)
  #--------------------------------------------------------------------------
  def change_sound(value)
    @volume_sound += value
    if @volume_sound > 100
      @volume_sound = 100
    elsif @volume_sound < 1
      @volume_sound = 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 改變音樂音量(單位畫格)
  #--------------------------------------------------------------------------
  def change_music(value)
    @volume_music += value
    if @volume_music > 100
      @volume_music = 100
    elsif @volume_music < 1
      @volume_music = 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 改變亮度(單位畫格)
  #--------------------------------------------------------------------------
  def change_brightness(value)
    @brightness += value
    if @brightness > 455
      @brightness = 455
    elsif @brightness < 55
      @brightness = 55
    end
  end
end


#encoding:utf-8
#==============================================================================
# ■ Scene_Base
#------------------------------------------------------------------------------
# 　游戲中所有 Scene 類（場景類）的父類
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_system_option_on_Scene_Base_alias
    alias lctseng_for_system_option_on_Scene_Base_for_Start start # 開始處理
    alias lctseng_for_system_option_on_Scene_Base_for_Terminate terminate # 結束處理
    @lctseng_for_system_option_on_Scene_Base_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 開始處理 - 重新定義
  #--------------------------------------------------------------------------
  def start
    set_system_option
    lctseng_for_system_option_on_Scene_Base_for_Start
    create_brightness_viewport
  end
  #--------------------------------------------------------------------------
  # ● 結束處理 - 重新定義
  #--------------------------------------------------------------------------
  def terminate
    lctseng_for_system_option_on_Scene_Base_for_Terminate
    dispose_brightness_viewport
  end
  #--------------------------------------------------------------------------
  # ● 產生亮度調整用顯示端口
  #--------------------------------------------------------------------------
  def create_brightness_viewport
    @viewport_brightness = Viewport.new
    @viewport_brightness.z = 5000
    adjust_brightness
  end
  #--------------------------------------------------------------------------
  # ● 釋放亮度調整用顯示端口
  #--------------------------------------------------------------------------
  def dispose_brightness_viewport
    @viewport_brightness.dispose
  end
  #--------------------------------------------------------------------------
  # ● 執行修正亮度
  #--------------------------------------------------------------------------
  def adjust_brightness
    minus = @system_data.brightness - 255
    @viewport_brightness.tone.red = minus
    @viewport_brightness.tone.green = minus
    @viewport_brightness.tone.blue = minus
  end
  #--------------------------------------------------------------------------
  # ● 取得系統資訊物件
  #--------------------------------------------------------------------------
  def system_data_object
    @system_data
  end
  #--------------------------------------------------------------------------
  # ● 重設系統資訊
  #--------------------------------------------------------------------------
  def set_system_option
    @system_data = load_system_data
    Audio.set_music_rate(@system_data.volume_music)
    Audio.set_sound_rate(@system_data.volume_sound)
  end
  #--------------------------------------------------------------------------
  # ● 讀取系統設定資訊
  #--------------------------------------------------------------------------
  def load_system_data
    begin
      return load_system_data_directly 
    rescue
      puts "原有資訊不存在，創立新檔案"
      data = write_new_data
      return data
    end
  end
  #--------------------------------------------------------------------------
  # ● 讀取系統設定資訊(直接讀取)
  #--------------------------------------------------------------------------
  def load_system_data_directly
    File.open("SystemOption", "rb") do |file|
      puts "正在讀取原有資訊"
      return Marshal.load(file)
    end
  end
  #--------------------------------------------------------------------------
  # ● 寫入新的系統設定資訊檔案
  #--------------------------------------------------------------------------
  def write_new_data
    new_data = Game_SystemOption.new
    File.open("SystemOption", "wb") do |file|
      Marshal.dump(new_data, file)
    end
    return new_data
  end
  #--------------------------------------------------------------------------
  # ● 寫入系統設定資訊檔案
  #--------------------------------------------------------------------------
  def write_system_data
    save_data(system_data_object,"SystemOption")
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面（基礎）
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update
    Input.update
    update_all_windows
  end
end


#encoding:utf-8
#==============================================================================
# ■ Scene_SystemOption
#------------------------------------------------------------------------------
# 　系統選單的管理
#==============================================================================

class Scene_SystemOption < Scene_Base

  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    create_back_ground
    create_arrow
    create_bar
    @index = 0
    @stop = true
    @allow_change = true
  end
  #--------------------------------------------------------------------------
  # ● 產生背景
  #--------------------------------------------------------------------------
  def create_back_ground
    @back_ground = Sprite.new(@viewport)
    @back_ground.bitmap = Cache.system("System_Option_Background")
  end
  #--------------------------------------------------------------------------
  # ● 產生箭頭
  #--------------------------------------------------------------------------
  def create_arrow
    @arrow_sprite = Sprite_OptionArrow.new(@viewport)
  end
  #--------------------------------------------------------------------------
  # ● 產生比率條精靈組
  #--------------------------------------------------------------------------
  def create_bar
    @bar_spritesets = []
    system_data_object.data_rates.each_with_index do |rate,index|
      @bar_spritesets.push(Spriteset_OptionBar.new(index,rate))
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景
  #--------------------------------------------------------------------------
  def dispose_back_ground
    @back_ground.bitmap.dispose
    @back_ground.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放箭頭
  #--------------------------------------------------------------------------
  def dispose_arrow
    @arrow_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    dispose_back_ground
    dispose_arrow
    dispose_bar
    super
  end
  #--------------------------------------------------------------------------
  # ● 釋放比率
  #--------------------------------------------------------------------------
  def dispose_bar
    @bar_spritesets.each do |sprite|
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新箭頭
  #--------------------------------------------------------------------------
  def update_arrow
    @arrow_sprite.update_pos(@index)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_command
    update_arrow
  end
  #--------------------------------------------------------------------------
  # ● 更新指令
  #--------------------------------------------------------------------------
  def update_command
    if @allow_change
      changing = false
      if Input.press?(:RIGHT)
        changing = true
        @stop = false
        update_right
      elsif Input.press?(:LEFT)
        changing = true
        @stop = false
        update_left
      end
      if !changing
        if !@stop
          @stop = true
          process_on_stop
        end
        if Input.trigger?(:B)
          write_system_data
          return_scene
        end
        if (Input.trigger?(:C) && @index == 3 ) 
          system_data_object.reset
          process_on_stop
          update_when_change
          adjust_brightness
        end
        if Input.repeat?(:UP)
          @index -= 1
          if @index < 0
            @index = 3
          end
          moving = true
        elsif Input.repeat?(:DOWN)
          @index += 1
          @index %= 4
          moving = true
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 停止時的處理
  #--------------------------------------------------------------------------
  def process_on_stop
    case @index
    when 0
      Audio.set_music_rate_with_effect(system_data_object.volume_music)
    when 1
      Audio.set_sound_rate_with_effect(system_data_object.volume_sound)
    when 3
      Audio.set_music_rate_with_effect(system_data_object.volume_music)
      Audio.set_sound_rate_with_effect(system_data_object.volume_sound)
    end
    puts "執行停止"
    write_system_data
    puts "三項資料：#{system_data_object.data_array}"
  end
  #--------------------------------------------------------------------------
  # ● 更換比率後的更新
  #--------------------------------------------------------------------------
  def update_when_change
    if @index > 2
      3.times do |index|
        @bar_spritesets[index].update_rate(system_data_object.data_rates[index])
      end
    else
      @bar_spritesets[@index].update_rate(system_data_object.data_rates[@index])
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 更新右移
  #--------------------------------------------------------------------------
  def update_right
    case @index
    when 0
      system_data_object.change_music(1)
    when 1
      system_data_object.change_sound(1)
    when 2
      system_data_object.change_brightness(1)
      adjust_brightness
    end
    update_when_change
  end
  #--------------------------------------------------------------------------
  # ● 更新左移
  #-------------------------------------------------------------------------
  def update_left
    case @index
    when 0
      system_data_object.change_music(-1)
    when 1
      system_data_object.change_sound(-1)
    when 2
      system_data_object.change_brightness(-1)
      adjust_brightness
    end
    update_when_change
  end
end


#encoding:utf-8
#==============================================================================
# ■ Spriteset_OptionBar
#      系統設定裡的比率條精靈組
#==============================================================================

class Spriteset_OptionBar
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(index,rate)
    @index = index
    @rate = rate
    create_viewport
    create_sprite
  end
  #--------------------------------------------------------------------------
  # ● 取得顯示端口用的矩形
  #--------------------------------------------------------------------------
  def get_viewport_rect
    ry = Lctseng::SystemOption::Bar_Y[@index]
    if !ry
      ry = 0
    end
    return Rect.new(Lctseng::SystemOption::Bar_X,ry,Lctseng::SystemOption::Bar_Width,Lctseng::SystemOption::Bar_Height)
  end
  #--------------------------------------------------------------------------
  # ● 產生顯示端口
  #--------------------------------------------------------------------------
  def create_viewport
    @viewport = Viewport.new(get_viewport_rect)
    @viewport.rect.width = Lctseng::SystemOption::Bar_Width * @rate
    @viewport.z = 200
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈
  #--------------------------------------------------------------------------
  def create_sprite
    @sprite = Sprite.new(@viewport)
    @sprite.bitmap = Cache.system("System_Option_Bar")
  end
  #--------------------------------------------------------------------------
  # ● 更新比率
  #--------------------------------------------------------------------------
  def update_rate(rate)
    @rate = rate
    update_viewport
  end
  #--------------------------------------------------------------------------
  # ● 更新顯示端口
  #--------------------------------------------------------------------------
  def update_viewport
    @viewport.rect.width = Lctseng::SystemOption::Bar_Width * @rate
  end
  #--------------------------------------------------------------------------
  # ● 釋放精靈
  #--------------------------------------------------------------------------
  def dispose_sprite
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放顯示端口
  #--------------------------------------------------------------------------
  def dispose_viewport
    @viewport.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    dispose_sprite
    dispose_viewport
  end
end


#encoding:utf-8
#==============================================================================
# ■ Sprite_OptionArrow
#      系統設定裡的箭頭精靈
#==============================================================================

class Sprite_OptionArrow < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Cache.system("System_Option_Arrow")
    self.x = Lctseng::SystemOption::ARROW_X
    update_pos(0)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_pos(index)
    ry = Lctseng::SystemOption::ARROW_Y[index]
    if !ry
      ry = 0
    end
    self.y =  ry
  end
end
