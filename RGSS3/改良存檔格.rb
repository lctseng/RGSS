#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 強化存檔格 ＊

                       for RGSS3

        Ver 1.02   2013.07.27

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、功能較多的存檔格


    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.DataManager
                          2.Game_Party
                          3.Game_Interpreter
                          4.Window_SaveFile
                          5.Scene_File
                          6.Scene_Save
                          7.Scene_Load
                          
                          
                        二、新定義的類別：
                          1.Window_Save_Decision
                          2.Window_Load_Decision
                        
                          
                        三、可供修改的模組與全域變數
                          1.是否啟用強化存檔格：$Lctseng_Enable_SaveSlot_Plus
                          2.是否啟用事件強制存檔：$Lctseng_Enable_Auto_Save
                          3.在強化存檔格中，是否在存檔格繪製角色名稱：$Lctseng_SaveFileEX_Enable_Draw_Actor_Name
                          4.其他設定：Lctseng_Save_Plus_Settings
                        
                          
                          

*******************************************************************************************

=end


$Lctseng_Enable_SaveSlot_Plus  = true #是否啟用強化存檔格
$Lctseng_Enable_Auto_Save  = true #是否啟用事件強制存檔
$Lctseng_SaveFileEX_Enable_Draw_Actor_Name = true #在強化存檔格中，是否在存檔格繪製角色名稱

module Lctseng_Save_Plus_Settings
  
  MAX_SAVE_SLOT = 16 #最大的存檔格數，不包含自動存檔格，開啟自動存檔後，此數目可以為0
  
  NAME_OF_AUTO_SAVE_FILE = "自動" #自動存檔格的名稱
  
  THE_POSITION_OF_ACTOR_NAMES = 75 #繪製角色名稱時的Y座標
  
  
end

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
$lctseng_scripts[:save_file_ex] = "1.02"

puts "載入腳本：Lctseng - 強化存檔格，版本：#{$lctseng_scripts[:save_file_ex]}"


#encoding:utf-8
#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　數據庫和游戲實例的管理器。所有在游戲中使用的全局變量都在這里初始化。
#==============================================================================

module DataManager
  include Lctseng_Save_Plus_Settings
  #--------------------------------------------------------------------------
  # ● 存檔文件的最大數 - 重新定義
  #--------------------------------------------------------------------------
  class << self 
    alias lctseng_savefile_max savefile_max
  end
  #--------------------------------------------------------------------------
  def self.savefile_max
    return $Lctseng_Enable_Auto_Save ? MAX_SAVE_SLOT  + 1   : MAX_SAVE_SLOT
  end
  #--------------------------------------------------------------------------
  # ● 取得現實時間字串
  #--------------------------------------------------------------------------
  def self.gain_time_string
    time = Time.new
    return time.strftime("%Y年%m月%d日(%a)%X ") 
  end
  #--------------------------------------------------------------------------
  # ● 生成存檔的頭數據  - 重新定義
  #--------------------------------------------------------------------------
  class << self 
    alias lctseng_make_save_header make_save_header
  end
  #--------------------------------------------------------------------------
  def self.make_save_header 
    header = {}
    header[:characters] = $game_party.characters_for_savefile
    header[:names] = $game_party.names_for_savefile
    header[:playtime_s] = $game_system.playtime_s
    header[:time_log] = gain_time_string
    header[:map_name] = $game_map.display_name
    header
  end
end


#encoding:utf-8
#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　管理隊伍的類。保存有金錢及物品的信息。本類的實例請參考 $game_party 。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 存檔文件顯示用的角色圖像信息 - 重新定義 - 臉圖
  #--------------------------------------------------------------------------
  alias lctseng_characters_for_savefile  characters_for_savefile
  #--------------------------------------------------------------------------
  def characters_for_savefile
    unless $Lctseng_Enable_SaveSlot_Plus
      lctseng_characters_for_savefile
    else
      battle_members.collect do |actor|
        [actor.face_name, actor.face_index]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 存檔文件顯示用的角色名稱
  #--------------------------------------------------------------------------
  def names_for_savefile
      battle_members.collect do |actor|
        actor.name#sprintf("Lv:%d",actor.level)
      end
  end
end


#encoding:utf-8
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解釋器。
#   本類在 Game_Map、Game_Troop、Game_Event 類的內部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 執行自動存檔
  #--------------------------------------------------------------------------
  def excute_auto_save
    DataManager.save_game(0) if $Lctseng_Enable_Auto_Save
  end
end


#==============================================================================
# ■ Window_Save_Decision
#==============================================================================

class Window_Save_Decision < Window_HorzCommand

  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(x =  (Graphics.width - window_width )/2 , y=   (Graphics.height / 2 ) -( line_height / 2 )  )
    super(x, y)
    self.z  =  300
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的寬度
  #--------------------------------------------------------------------------
  def window_width
    return 300
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    return 50
  end
  #--------------------------------------------------------------------------
  # ● 是否開啟
  #--------------------------------------------------------------------------
  def show?
    return self.visible
  end
  #--------------------------------------------------------------------------
  # ● 獲取列數
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    s=["確定存檔", "取消" ]         #設定選項名稱
    add_command( s[0] ,    :sr_ok)    
    add_command( s[1] ,    :sr_no)    
  end
end

#==============================================================================
# ■ Window_Load_Decision
#==============================================================================

class Window_Load_Decision < Window_HorzCommand

  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(x =  (Graphics.width - window_width) /2, y=   (Graphics.height / 2 ) -( line_height / 2 )  )
    super(x, y)
    self.z  =  300
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的寬度
  #--------------------------------------------------------------------------
  def window_width
    return 300
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的高度
  #--------------------------------------------------------------------------
  def window_height
    return 50
  end
  #--------------------------------------------------------------------------
  # ● 是否開啟
  #--------------------------------------------------------------------------
  def show?
    return self.visible
  end
  #--------------------------------------------------------------------------
  # ● 獲取列數
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    s=["確定讀檔", "取消" ]         #設定選項名稱
    add_command( s[0] ,    :lr_ok)    
    add_command( s[1] ,    :lr_no)    
  end
end

#encoding:utf-8
#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　存檔畫面和讀檔畫面中顯示存檔文件的窗口。
#==============================================================================

class Window_SaveFile < Window_Base

  #--------------------------------------------------------------------------
  # ● 刷新 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_refresh refresh
  #--------------------------------------------------------------------------
  def refresh
    unless $Lctseng_Enable_SaveSlot_Plus
      contents.clear
      change_color(normal_color)
      if $Lctseng_Enable_Auto_Save
        if @file_index==0 
          name = Lctseng_Save_Plus_Settings::NAME_OF_AUTO_SAVE_FILE
        else
          name = Vocab::File + " #{@file_index }"
        end
      else
        name = Vocab::File + " #{@file_index +1}"
      end
      draw_text(4, 0, 200, line_height, name)
      @name_width = text_size(name).width
      draw_party_characters(152, 58)
      draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
      return 
    end
    contents.clear
    change_color(normal_color)
    if $Lctseng_Enable_Auto_Save
      if @file_index==0 
        name = Lctseng_Save_Plus_Settings::NAME_OF_AUTO_SAVE_FILE
      else
        name = Vocab::File + " #{@file_index }"
      end
    else
      name = Vocab::File + " #{@file_index +1}"
    end
    draw_text(4, 0, 200, line_height, name)
    @name_width = text_size(name).width
    draw_party_faces(0, line_height + 5)
    draw_party_names(0, line_height + Lctseng_Save_Plus_Settings::THE_POSITION_OF_ACTOR_NAMES) if $Lctseng_SaveFileEX_Enable_Draw_Actor_Name
    draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
    draw_time_log(0, 0 , contents.width - 4, 2)
    draw_map_log(0, contents.height - line_height, contents.width - 4, 0)
  end
  #--------------------------------------------------------------------------
  # ● 繪制隊伍肖像
  #--------------------------------------------------------------------------
  def draw_party_faces(x, y)
    header = DataManager.load_header(@file_index)
    return unless header
    header[:characters].each_with_index do |data, i|
      draw_face(data[0], data[1], x + i * 100, y) rescue nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪制隊員名字 
  #--------------------------------------------------------------------------
  def draw_party_names(x, y,width = 100)
    header = DataManager.load_header(@file_index)
    return unless header
    return unless header[:names]
    header[:names].each_with_index do |name, i|
       draw_text( x + i * 100, y, width, line_height, name) rescue nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 繪制游戲時間 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_draw_playtime draw_playtime
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    unless $Lctseng_Enable_SaveSlot_Plus
      lctseng_draw_playtime(x, y, width, align)
      return 
    end
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height,"遊戲時間：" + header[:playtime_s], 2)
  end
  #--------------------------------------------------------------------------
  # ● 繪制存檔時的現實時間
  #--------------------------------------------------------------------------
  def draw_time_log(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height,  header[:time_log], align) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 繪制存檔時的所在地圖
  #--------------------------------------------------------------------------
  def draw_map_log(x, y, width, align)
    header = DataManager.load_header(@file_index)
    return unless header
    draw_text(x, y, width, line_height, "所在地圖：" + header[:map_name], align) rescue nil
  end
  end

#encoding:utf-8
#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　存檔畫面和讀檔畫面共同的父類
#==============================================================================

class Scene_File < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始處理 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_start start
  #--------------------------------------------------------------------------
  def start
    lctseng_start
    create_decision_windows
  end
  #--------------------------------------------------------------------------
  # ● 獲取可顯示的存檔數目 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_visible_max visible_max
  #--------------------------------------------------------------------------
  def visible_max
    unless $Lctseng_Enable_SaveSlot_Plus
      return lctseng_visible_max
    end
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 生成確認視窗
  #--------------------------------------------------------------------------
  def create_decision_windows
    @save_decision = Window_Save_Decision.new
    @load_decision = Window_Load_Decision.new
    @save_decision.hide
    @load_decision.hide
    @save_decision.deactivate
    @load_decision.deactivate
    @save_decision.set_handler(:sr_ok   ,method(:on_save_really_ok  ))
    @save_decision.set_handler(:sr_no   ,method(:on_save_really_no  ))
    @load_decision.set_handler(:lr_ok   ,method(:on_load_really_ok  ))
    @load_decision.set_handler(:lr_no   ,method(:on_load_really_no  ))    
    @load_decision.set_handler(:cancel   ,method(:on_load_really_no  ))    
  end
  #--------------------------------------------------------------------------
  # ● 存檔文件“取消” - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_on_savefile_cancel on_savefile_cancel
  #--------------------------------------------------------------------------
  def on_savefile_cancel
    if @save_decision.active
      on_save_really_no
    elsif @load_decision.active
      on_load_really_ok
    else
      lctseng_on_savefile_cancel
    end
  end 
  #--------------------------------------------------------------------------
  # ● 更新光標 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_saveEX_update_cursor update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @save_decision.active || @load_decision.active
      
    else
      lctseng_saveEX_update_cursor
    end
  end
  #--------------------------------------------------------------------------
  # ● 確認存檔
  #--------------------------------------------------------------------------
  def on_save_really_ok
  end
  #--------------------------------------------------------------------------
  # ● 取消存檔
  #--------------------------------------------------------------------------
  def on_save_really_no
  end
  #--------------------------------------------------------------------------
  # ● 確認讀檔
  #--------------------------------------------------------------------------
  def on_load_really_ok
  end
  #--------------------------------------------------------------------------
  # ● 取消讀檔
  #--------------------------------------------------------------------------
  def on_load_really_no
  end
end

#encoding:utf-8
#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　存檔畫面
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● 確定存檔文件 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_on_savefile_ok on_savefile_ok
  #--------------------------------------------------------------------------
  def on_savefile_ok
    if @index == 0&&$Lctseng_Enable_Auto_Save
      Sound.play_buzzer
      return
    end
    @savefile_windows.each {|window| window.deactivate }
    if Dir.glob(DataManager.make_filename(@index)).empty?
      @save_decision.select(0)
    else
      @save_decision.select(1)
    end
    @save_decision.show
    @save_decision.activate
    Sound.play_ok
  end
  #--------------------------------------------------------------------------
  # ● 確認存檔
  #--------------------------------------------------------------------------
  def on_save_really_ok
    @savefile_windows.each {|window| window.activate }
    @save_decision.hide
    @save_decision.deactivate
    lctseng_on_savefile_ok
  end
  #--------------------------------------------------------------------------
  # ● 取消存檔
  #--------------------------------------------------------------------------
  def on_save_really_no
    @savefile_windows.each {|window| window.activate }
    @save_decision.hide
    @save_decision.deactivate
    Sound.play_cancel
  end
  #--------------------------------------------------------------------------
  # ● 存檔成功時的處理 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_on_save_success on_save_success
   #--------------------------------------------------------------------------
  def on_save_success
    Sound.play_save
    @savefile_windows[@index].refresh#.each {|window| window.refresh }
  end
end

#encoding:utf-8
#==============================================================================
# ■ Scene_Load
#------------------------------------------------------------------------------
# 　讀檔畫面
#==============================================================================

class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_savefile_ex_alias
    alias lctseng_for_savefile_ex_On_savefile_ok on_savefile_ok # 確定讀檔文件
    @lctseng_for_savefile_ex_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 確定讀檔文件
  #--------------------------------------------------------------------------
  def on_savefile_ok
    @savefile_windows.each {|window| window.deactivate }
    @load_decision.select(0)
    @load_decision.show
    @load_decision.activate
    Sound.play_ok
  end
  #--------------------------------------------------------------------------
  # ● 確認讀檔
  #--------------------------------------------------------------------------
  def on_load_really_ok
    @savefile_windows.each {|window| window.activate }
    @load_decision.hide
    @load_decision.deactivate
    lctseng_for_savefile_ex_On_savefile_ok
  end
  #--------------------------------------------------------------------------
  # ● 取消讀檔
  #--------------------------------------------------------------------------
  def on_load_really_no
    @savefile_windows.each {|window| window.activate }
    @load_decision.hide
    @load_decision.deactivate
    Sound.play_cancel
  end
end

  
