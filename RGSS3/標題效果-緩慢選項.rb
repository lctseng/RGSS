#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 標題特效#1 緩慢選項＊

                       for RGSS3

        Ver 1.00   2014.04.20

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版
   原為替"wer227942914(小羽貓咪)"撰寫的特製版本
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、標題緩慢出現選項的效果

   更新紀錄：
    Ver 1.00 ：
    日期：2014.04.20
    摘要：一、最初版本
                二、功能：                  
                       一、標題緩慢出現選項的效果

    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           1. Scene_Title
                           
                           
                        二、此腳本提供可供設定的模組：
                          1.Lctseng::TitleSlowCommand
                           
                          

*******************************************************************************************

=end

#==============================================================================
# ■ Lctseng::TitleSlowCommand
#------------------------------------------------------------------------------
# 　閃爍標題圖層設定用模組
#==============================================================================
module Lctseng
module TitleSlowCommand
  #--------------------------------------------------------------------------
  # ● 前景淡出時間
  #--------------------------------------------------------------------------
  FOREGROUND_FADE_TIME = 60
  #--------------------------------------------------------------------------
  # ● 指令切換時間
  #--------------------------------------------------------------------------
  COMMAND_CHANGE_TIME = 5
  
end
end



#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#******************************************************************************************



#--------------------------------------------------------------------------
# ★ 紀錄腳本資訊
#--------------------------------------------------------------------------
if !$lctseng_scripts  
  $lctseng_scripts = {}
end
$lctseng_scripts[:title_01_slow_command] = "1.00"

puts "載入腳本：Lctseng - 標題特效#1 緩慢選項，版本：#{$lctseng_scripts[:title_01_slow_command]}"

#encoding:utf-8
#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　標題畫面
#==============================================================================

class Scene_Title 
  #--------------------------------------------------------------------------
  # ● 類變數
  #--------------------------------------------------------------------------
  @@has_show_first_time = false
  #--------------------------------------------------------------------------
  # ● 加入模組
  #--------------------------------------------------------------------------
  include Lctseng::TitleSlowCommand
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    Graphics.freeze
    create_command_sprites
    create_background
    create_foreground
    create_flash_sprite
    create_role_sprite
    @fore_gound_fade_speed = 255.0 / FOREGROUND_FADE_TIME
    if DataManager.save_file_exists?
      @default_index =  1
    else
      @default_index =  0
    end
    @current_index = @default_index
    #create_command_window
    play_title_music
    if @@has_show_first_time
      @phase = :main
      @sprite2.opacity = 0
      @command_sprites.each_with_index do |sprite,i|
        sprite.set_min_opacity(160)
        if i == @default_index
          sprite.fade_in(30)
        end
        
      end
    else
      @phase = :init
    end
  end
  #--------------------------------------------------------------------------
  # ● 產生標題指令精靈
  #--------------------------------------------------------------------------
  def create_command_sprites
    @command_sprites = []
    3.times do |i|
      @command_sprites.push(Sprite_TitleCommand.new(i))
    end
  end
  #--------------------------------------------------------------------------
  # ● 產生閃爍精靈
  #--------------------------------------------------------------------------
  def create_flash_sprite
    @flash_sprite = Sprite_TitleFlash.new
  end
  #--------------------------------------------------------------------------
  # ● 產生角色精靈
  #--------------------------------------------------------------------------
  def create_role_sprite
    @role_sprite = []
    0.times do |i|
      sprite = Sprite.new
      sprite.z = 20 + i
      sprite.bitmap = Cache.system(sprintf("Role_%02d",i+1))
      @role_sprite.push(sprite)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    update_for_effect
    #puts @phase
    case @phase
    when :init
      wait(60)
      fade_in_commands
      @phase = :wait_enter
    when :wait_enter
      if Input.trigger?(:C)
        @@has_show_first_time = true
        fade_out_foreground
        @phase = :main
      end
    when :main
      update_command_select
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新閃爍精靈
  #--------------------------------------------------------------------------
  def update_flash_sprite
    @flash_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 淡出前景
  #--------------------------------------------------------------------------
  def fade_out_foreground
    @command_sprites.each_with_index do |sprite,i|
      sprite.set_min_opacity(160)
      if i != @default_index
        sprite.fade_out(FOREGROUND_FADE_TIME)
      end
    end
    FOREGROUND_FADE_TIME.times do 
      update_for_wait
      @sprite2.opacity -= @fore_gound_fade_speed
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新指令選擇
  #--------------------------------------------------------------------------
  def update_command_select
    #puts @current_index
    if Input.trigger?(:C)
      case @current_index
      when 0
        command_new_game
      when 1
        command_continue
      when 2
        command_shutdown
      end
    elsif Input.trigger?(:RIGHT)
      @current_index -= 1
      @current_index = 2 if @current_index < 0
      Sound.play_cursor
    elsif Input.trigger?(:LEFT)
      @current_index += 1
      @current_index = 0 if @current_index > 2
      Sound.play_cursor
    end
    @command_sprites.each do |sprite|
      if sprite.index == @current_index
        sprite.fade_in(COMMAND_CHANGE_TIME)
      else
        sprite.fade_out(COMMAND_CHANGE_TIME)
      end
    end
    update_for_wait while @command_sprites.any? {|sprite| sprite.fading?}
    
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times do 
      update_for_wait
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡入標題指令
  #--------------------------------------------------------------------------
  def fade_in_commands
    @command_sprites.each do |sprite|
      sprite.fade_in(90)
      update_for_wait while sprite.fading?
      wait(60)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新效果
  #--------------------------------------------------------------------------
  def update_for_effect
    update_command_sprites
    update_flash_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新等待
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
    update_for_effect
  end
  #--------------------------------------------------------------------------
  # ● 更新指令精靈
  #--------------------------------------------------------------------------
  def update_command_sprites
    @command_sprites.each do |sprite|
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取漸變速度
  #--------------------------------------------------------------------------
  def transition_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● 釋放指令精靈
  #--------------------------------------------------------------------------
  def dispose_command_sprites
    @command_sprites.each do |sprite|
      sprite.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放閃爍精靈
  #--------------------------------------------------------------------------
  def dispose_flash_sprite
    @flash_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放角色精靈
  #--------------------------------------------------------------------------
  def dispose_role_sprite
    @role_sprite.each do |sprite|
      sprite.dispose
    end
    
  end
  
  #--------------------------------------------------------------------------
  # ● 結束處理
  #--------------------------------------------------------------------------
  def terminate
    super
    SceneManager.snapshot_for_background
    dispose_background
    dispose_foreground
    dispose_command_sprites
    dispose_flash_sprite
    dispose_role_sprite
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new
    @sprite1.bitmap = Cache.title1($data_system.title1_name)
    @sprite2 = Sprite.new
    @sprite2.bitmap = Cache.title2($data_system.title2_name)
    center_sprite(@sprite1)
    center_sprite(@sprite2)
  end
  #--------------------------------------------------------------------------
  # ● 生成前景
  #--------------------------------------------------------------------------
  def create_foreground
    @foreground_sprite = Sprite.new
    @foreground_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @foreground_sprite.z = 100
    draw_game_title if $data_system.opt_draw_title
  end
  #--------------------------------------------------------------------------
  # ● 繪制游戲標題
  #--------------------------------------------------------------------------
  def draw_game_title
    @foreground_sprite.bitmap.font.size = 48
    rect = Rect.new(0, 0, Graphics.width, Graphics.height / 2)
    @foreground_sprite.bitmap.draw_text(rect, $data_system.game_title, 1)
  end
  #--------------------------------------------------------------------------
  # ● 釋放背景
  #--------------------------------------------------------------------------
  def dispose_background
    @sprite1.bitmap.dispose
    @sprite1.dispose
    @sprite2.bitmap.dispose
    @sprite2.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放前景
  #--------------------------------------------------------------------------
  def dispose_foreground
    @foreground_sprite.bitmap.dispose
    @foreground_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 執行精靈居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:shutdown, method(:command_shutdown))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:new_game, method(:command_new_game))
    #@command_window.visible = false
    #@command_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 關閉指令窗口
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  #--------------------------------------------------------------------------
  # ● 指令“開始游戲”
  #--------------------------------------------------------------------------
  def command_new_game
    DataManager.setup_new_game
    #close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● 指令“繼續游戲”
  #--------------------------------------------------------------------------
  def command_continue
    #close_command_window
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● 指令“退出游戲”
  #--------------------------------------------------------------------------
  def command_shutdown
    #close_command_window
    fadeout_all
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # ● 播放標題畫面音樂
  #--------------------------------------------------------------------------
  def play_title_music
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
end

#encoding:utf-8
#==============================================================================
# ■ Lctseng::TitleSlowCommand::Sprite_TitleCommand
#------------------------------------------------------------------------------
# 　顯示標題指令的精靈
#==============================================================================
module Lctseng::TitleSlowCommand
class Sprite_TitleCommand < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :index
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(index,viewport = nil)
    super(viewport)
    @index = index
    change_bitmap_now(true)
    @faded_in = false
    @fade_count = 0
    @fade_speed = 0.0
    @real_opacity = 0.0
    @min_opacity = 0
    self.opacity = @real_opacity
    self.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 更改圖片(立即)
  #--------------------------------------------------------------------------
  def change_bitmap_now(enable)
    @enable = enable
    if @enable
      self.bitmap = Cache.system("Poetry_#{@index+1}-1")
    else
      self.bitmap = Cache.system("Poetry_#{@index+1}-2")
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡入
  #--------------------------------------------------------------------------
  def fade_in(duration)
    return if fading? || @faded_in
    @faded_in = true
    @fade_count = duration
    @fade_speed = (255.0-@min_opacity) / duration
  end
  #--------------------------------------------------------------------------
  # ● 淡出
  #--------------------------------------------------------------------------
  def fade_out(duration)
    return if fading? || !@faded_in
    @faded_in = false
    @fade_count = duration
    @fade_speed = -1*(255.0-@min_opacity) / duration
  end
  #--------------------------------------------------------------------------
  # ● 設置最小透明度
  #--------------------------------------------------------------------------
  def set_min_opacity(val)
    @min_opacity = val.to_f
    @real_opacity = @min_opacity if @real_opacity < @min_opacity
     self.opacity = [@real_opacity,@min_opacity].max
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_opacity
  end
  #--------------------------------------------------------------------------
  # ● 是否淡入淡出中？
  #--------------------------------------------------------------------------
  def fading?
    @fade_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update_opacity
    if @fade_count > 0
      #puts "fading...#{@fade_count}"
      @fade_count -= 1
      @real_opacity += @fade_speed
      self.opacity = [@real_opacity,@min_opacity].max
    end
  end

end
end

#encoding:utf-8
#==============================================================================
# ■ Lctseng::TitleSlowCommand::Sprite_TitleFlash
#------------------------------------------------------------------------------
# 　顯示標題背景閃爍的精靈
#==============================================================================
module Lctseng::TitleSlowCommand
class Sprite_TitleFlash < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @change_count = 90
    @fade_count = 0
    @faded_in = true
    @real_opacity = self.opacity = 255
    self.z = 10
  end

  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    #puts "star : #{@change_count}"
    update_opacity
    if !fading?
      if @change_count > 0
        @change_count -= 1
      else
        @change_count = 90
        @need_change_bitmap = true
        fade_out(@change_count)
      end
    end
    

  end
  #--------------------------------------------------------------------------
  # ● 淡入
  #--------------------------------------------------------------------------
  def fade_in(duration)
    return if fading? || @faded_in
    @faded_in = true
    @fade_count = duration
    @fade_speed = (255.0) / duration
  end
  #--------------------------------------------------------------------------
  # ● 淡出
  #--------------------------------------------------------------------------
  def fade_out(duration)
    return if fading? || !@faded_in
    @faded_in = false
    @fade_count = duration
    @fade_speed = -1*(255.0) / duration
  end
  #--------------------------------------------------------------------------
  # ● 是否淡入淡出中？
  #--------------------------------------------------------------------------
  def fading?
    @fade_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 更新透明度
  #--------------------------------------------------------------------------
  def update_opacity
    if @fade_count > 0
      #puts "star fading...#{@fade_count}"
      @fade_count -= 1
      @real_opacity += @fade_speed
      self.opacity = @real_opacity
    elsif @need_change_bitmap
      @need_change_bitmap = false
      self.bitmap = Cache.system(sprintf("Star_%02d",rand(4)+1))
    elsif !@faded_in
      fade_in(90)
    end
  end



end
end

#==============================================================================
# ■ 以下2個腳本組為擴增的外來腳本，主要是控制飄落物
#==============================================================================

#--------------------------------------------------------------------------
# ● 光拡散エフェクト
#--------------------------------------------------------------------------

=begin
      RGSS3
      
      ★ 光拡散エフェクト ★

      光が広がったり、集まったり、降ったりします。
      天候と似た使い方を想定しています。
      
      イベントコマンドのスクリプトから起動させてください。
      
      ● コマンド一覧 ●==================================================
      start_effect(type)
      --------------------------------------------------------------------
      光拡散エフェクトを開始します。
      引数の値によってエフェクトの種類が決定します
        1  => 中心から発散
        2  => 中心へ収束
        3  => 中央上部から下へ
        4  => 上部全体から下へ
        5  => 右上から左下へ
        
        21 => 不規則な螺旋を描いて上昇
        22 => ゆらゆらと上昇
        23 => 規則正しい螺旋を描いて上昇
        
        31 => 雪
      ====================================================================
      end_effect
      --------------------------------------------------------------------
      エフェクトの終了。画面上のエフェクトをすべて一気に開放します。
      ====================================================================
      end_effect_fade
      --------------------------------------------------------------------
      エフェクトの終了。画面上のエフェクトを少しづつ開放します。
      ====================================================================
      
      ver1.10

      Last Update : 2012/03/24
      03/24 : 雪エフェクトの追加
      ----------------------2012--------------------------
      12/17 : RGSS2からの移植
      ----------------------2011--------------------------
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end

$rsi ||= {}
$rsi["光拡散エフェクト"] = true

module Reffect
  @@span = false
  def initialize(viewport)
    @sp = [0, 0]     # 初期座標
    @ma = [0.0, 0.0] # 移動角度(ラジアン)
    @rd = 0.0        # 初期座標からの半径
    super(viewport)
    self.blend_type = 1
    @@span ^= true
  end
  def width
    Graphics.width
  end
  def height
    Graphics.height
  end
  def zoom=(value)
    self.zoom_x = self.zoom_y = value
  end
  def setGraphic(filename)
    self.bitmap = Cache.system(filename)
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
  def setStartPosition(typeX, typeY)
    case typeX
    when 0 # ランダム
      @sp[0] = rand(width + 100) - 50
    when 1 # 画面外(左)
      @sp[0] = -30
    when 2 # 中央
      @sp[0] = width / 2
    when 3 # 画面外(右)
      @sp[0] = width + 30
    end
    case typeY
    when 0 # ランダム
      @sp[1] = rand(height + 50) - 25
    when 1 # 画面外(上)
      @sp[1] = -30
    when 2 # 中央
      @sp[1] = height / 2
    when 3 # 画面外(下)
      @sp[1] = height + 30
    end
    self.x = @sp[0]
    self.y = @sp[1]
  end
  def setMoveAngle(ax, ay = ax)
    @ma[0] = Math.cos(ax * 0.01)
    @ma[1] = Math.sin(ay * 0.01)
  end
  def getX
    @sp[0] + @rd * @ma[0]
  end
  def getY
    @sp[1] + @rd * @ma[1]
  end
  def getZoom
    (@rd * @ma[1] / width / 1.5 + 0.8) * (self.opacity / 200.0)
  end
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :r_effect_sprites # 特殊効果スプライト群
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias r_effect_initialize initialize
  def initialize
    r_effect_initialize
    @r_effect_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_r_effect
    @r_effect_sprites.each{|sprite| sprite.dispose}
    @r_effect_sprites = []
  end
end

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :r_effect_type # 特殊効果の種類
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias r_effect_initialize initialize
  def initialize
    r_effect_initialize
    @r_effect_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の開始
  #--------------------------------------------------------------------------
  def start_effect(type)
    $game_temp.dispose_r_effect if @r_effect_type != type
    @r_effect_type = type
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（瞬時）
  #--------------------------------------------------------------------------
  def end_effect
    $game_temp.dispose_r_effect
    @r_effect_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（フェード）
  #--------------------------------------------------------------------------
  def end_effect_fade
    @r_effect_type = 0
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 特殊効果の開始
  #--------------------------------------------------------------------------
  def start_effect(type)
    $game_system.start_effect(type)
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（瞬時）
  #--------------------------------------------------------------------------
  def end_effect
    $game_system.end_effect
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（フェード）
  #--------------------------------------------------------------------------
  def end_effect_fade
    $game_system.end_effect_fade
  end
end

class Sprite_Reffect_Diffusion < Sprite
  #--------------------------------------------------------------------------
  # ● インクルード Reffect
  #--------------------------------------------------------------------------
  include Reffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    if rand(100) > 20
      @graphic_id = 1
    else
      @graphic_id = rand(4)+2
      #if @graphic_id == 3
      #  @graphic_id = 1
      #end
    end
    @picture_id = rand(8) + 1
    case $game_system.r_effect_type
    when 1
      @rd = rand(width / 3).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(2, 2)
      setMoveAngle(rand(2 * Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    when 2
      @rd = rand(width / 3).to_f + 30.0
      @moveSpeed = rand(50).next * -0.01 - 0.5
      @existCount = rand(100) + 90
      setStartPosition(2, 2)
      setMoveAngle(rand(2 * Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    when 3
      @rd = rand(width / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(2, 1)
      setMoveAngle(rand(2 * Math::PI * 100), rand(Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    when 4
      @rd = rand(width / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(0, 1)
      setMoveAngle(rand(2 * Math::PI * 100), rand(Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    when 5
      @rd = rand(width / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 120
      setStartPosition(3, 1)
      setMoveAngle(rand(Math::PI * 100) + 90, rand(Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    when 6
      @rd = rand(width / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5  + 1
      @existCount = rand(100) + 120
      setStartPosition(1, 1)
      setMoveAngle(rand(130)+25,rand(130))
      #setMoveAngle(rand(Math::PI * 100) + 45, rand(Math::PI * 100))
      setGraphic(filename_by_id($game_system.r_effect_type))
    end
    @maxOpacity = rand(160) + 90 #40
    @picture_change_count = 10
    self.opacity = 1
  end
  #--------------------------------------------------------------------------
  # ● 利用編號產生檔名
  #--------------------------------------------------------------------------
  def filename_by_id(id)
    sprintf("Sakura_%d/Sample_%d-%02d",@graphic_id,@graphic_id,id)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if self.opacity.zero?
      dispose
      $game_temp.r_effect_sprites.delete(self)
    else
      if @picture_change_count <= 0
        @picture_change_count = 5
        @picture_id = @picture_id + 1
        if @picture_id > 17
          @picture_id = 1
        end
        setGraphic(filename_by_id(@picture_id))
      else
        @picture_change_count -= 1
      end
      @existCount -= 1
      @rd = [@rd + @moveSpeed, 0.0].max
      self.x = getX
      self.y = getY
      self.zoom = getZoom
      self.opacity = [self.opacity + (@existCount > 0 ? 1 : -1), @maxOpacity].min
    end
  end
end

class Sprite_Reffect_Spiral < Sprite
  #--------------------------------------------------------------------------
  # ● インクルード Reffect
  #--------------------------------------------------------------------------
  include Reffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    case $game_system.r_effect_type
    when 21
      @rd = rand(200).next.to_f
      @moveSpeed = 5.0 - @rd / 50.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = 1
      setStartPosition(2, 3)
      setGraphic("RE_002")
    when 22
      @rd = rand(40).next.to_f
      @moveSpeed = rand(100).next * 0.01 + 1.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = rand(3).zero? ? 2 : 1
      setStartPosition(0, 3)
      setGraphic("RE_002")
    when 23
      @rd = 180
      @moveSpeed = 1.7
      @nextAngle = @@span ? 0.0 : 180.0
      @collapseSpeed = 0
      setStartPosition(2, 3)
      setGraphic("RE_002")
    end
    @floteY = self.y.to_f
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if self.y <= -self.oy || self.opacity.zero?
      dispose
      $game_temp.r_effect_sprites.delete(self)
    else
      @nextAngle += [@moveSpeed, 2].min
      @nextAngle = 0.0 if @nextAngle >= 360
      setMoveAngle(@nextAngle * 1.74533)
      self.x = getX
      self.y = (@floteY -= @moveSpeed).round
      self.zoom = getZoom
      self.opacity -= @collapseSpeed
    end
  end
end

class Sprite_Reffect_Snow < Sprite
  #--------------------------------------------------------------------------
  # ● インクルード Reffect
  #--------------------------------------------------------------------------
  include Reffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    setStartPosition(0, 1)
    setGraphic("RE_003")
    case rand(100)
    when 0..49
      self.zoom = (3 + rand(2)) / 10.0
    when 50..89
      self.zoom = (6 + rand(2)) / 10.0
    when 90..99
      self.zoom = (9 + rand(2)) / 10.0
    end
    self.z = self.zoom_x * 10
    @moveSpeed = self.zoom_x * 1.6
    @floteY = self.y.to_f
    @rd = rand(10).next.to_f
    @nextAngle = rand(360).to_f
    @existCount = 1500
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if self.y > height || self.opacity.zero?
      dispose
      $game_temp.r_effect_sprites.delete(self)
    else
      @existCount -= 3
      @nextAngle += [@moveSpeed, 2].min
      @nextAngle = 0.0 if @nextAngle >= 360
      setMoveAngle(@nextAngle * 1.74533)
      self.x = getX
      self.y = (@floteY += @moveSpeed).round
      self.opacity = @existCount
    end
  end
end

class Spriteset_Map
  @@re_add_count = 0
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias r_effect_dispose dispose
  def dispose
    r_effect_dispose
    $game_temp.dispose_r_effect
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias r_effect_update update
  def update
    r_effect_update
    update_r_effect
  end
  #--------------------------------------------------------------------------
  # ● 特殊エフェクトの更新
  #--------------------------------------------------------------------------
  def update_r_effect
    unless $game_system.r_effect_type.zero?
      if @@re_add_count.zero?
        case $game_system.r_effect_type
        when  1..10
          sprite = Sprite_Reffect_Diffusion.new(@viewport3)
          @@re_add_count = 10
        when 21..30
          sprite = Sprite_Reffect_Spiral.new(@viewport3)
          @@re_add_count = 10
        when 31..40
          sprite = Sprite_Reffect_Snow.new(@viewport3)
          @@re_add_count = 20
        end
        $game_temp.r_effect_sprites << sprite
      end
      @@re_add_count -= 1
    end
    $game_temp.r_effect_sprites.each{|sprite| sprite.update}
  end
end
#--------------------------------------------------------------------------
# ● 特殊エフェクト - タイトル表示プラグイン
#--------------------------------------------------------------------------


=begin
      RGSS3
      
      ★特殊エフェクト - タイトル表示プラグイン★
      
      マップで表示することを想定している「光拡散エフェクト」「スクリーンノイズ」
      をタイトルでも表示できるようにします。
      
      ver1.00

      Last Update : 2012/01/19
      01/19 : RGSS2からの移植
      
      ろかん　　　http://kaisou-ryouiki.sakura.ne.jp/
=end

#===========================================
#   設定箇所
#===========================================
module Rokan
module Title_in_Reffect
    # 光拡散エフェクト
    # 有効にする場合は「光拡散エフェクト」を別途導入してください。
    Reffective = true
    ReffectType = 6 # エフェクトの種類を指定
    
    # スクリーンノイズ
    # 有効にする場合は「スクリーンノイズ」を別途導入してください。
    NoiseEffective = false
end
end
#===========================================
#   ここまで
#===========================================

$rsi ||= {}
$rsi["特殊エフェクト - タイトル表示プラグイン"] = true

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ● インクルード Rokan::Title_in_Reffect
  #--------------------------------------------------------------------------
  include Rokan::Title_in_Reffect
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias _reffect_start start
  def start
    _reffect_start
    create_reffect
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias _reffect_terminate terminate
  def terminate
    _reffect_terminate
    dispose_reffect
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias _reffect_update_for_effect update_for_effect unless $!
  def update_for_effect
    _reffect_update_for_effect
    update_reffect
  end
  #--------------------------------------------------------------------------
  # ● 特殊エフェクトの作成
  #--------------------------------------------------------------------------
  def create_reffect
    if Reffective
      @re_add_count = 0
      @viewport = Viewport.new
      @viewport.z = 170
      $game_system.r_effect_type = ReffectType
    end
    if NoiseEffective
      $game_temp.r_noise_effect_spriteset = Spriteset_Noise.new
      $game_system.start_noise
    end
  end
  #--------------------------------------------------------------------------
  # ● 特殊エフェクトの解放
  #--------------------------------------------------------------------------
  def dispose_reffect
    if Reffective
      $game_system.r_effect_type = 0
      $game_temp.dispose_r_effect
      @viewport.dispose
    end
    if NoiseEffective && $game_temp.r_noise_effect_spriteset
      $game_system.r_noise_effect = false
      $game_temp.r_noise_effect_spriteset.dispose_noise
    end
  end
  #--------------------------------------------------------------------------
  # ● 特殊エフェクトのフレーム更新
  #--------------------------------------------------------------------------
  def update_reffect
    if Reffective
      unless $game_system.r_effect_type.zero?
        if @re_add_count.zero?
          case $game_system.r_effect_type
          when  1..20
            sprite = Sprite_Reffect_Diffusion.new(@viewport)
          when 21..30
            sprite = Sprite_Reffect_Spiral.new(@viewport)
          end
          $game_temp.r_effect_sprites << sprite
          @re_add_count = 10
        end
        @re_add_count -= 1
      end
      $game_temp.r_effect_sprites.each{|sprite| sprite.update}
    end
    if NoiseEffective && $game_temp.r_noise_effect_spriteset
      $game_temp.r_noise_effect_spriteset.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  alias _reffect_create_background create_background
  def create_background
    _reffect_create_background
    @sprite2.z = 80
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias _reffect_create_command_window create_command_window
  def create_command_window
    _reffect_create_command_window
    @command_window.z = 95
  end
end