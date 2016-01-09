#encoding:utf-8

#*******************************************************************************************
#
#   ＊ 對話 - 選項、存檔、暫停 ＊
#
#                       for RGSS3
#
#        Ver 1.03   2013.07.21
#
#   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
#   替"wer227942914(小羽貓咪)"撰寫的特製版本
#
#   轉載請保留此標籤
#
#   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
#
#   主要功能：
#                       一、合併兩個選項，製造高達八個選擇項
#                       二、將選項視窗改由左對齊
#                       三、暫停功能：暫停所有視窗並隱藏之，包含立繪，按鍵V
#                       四、存檔功能：在對話中可以進行存檔，按鍵SHIFT
#                       五、更改選項結果的傳遞方式：由Proc改為$game_system傳遞
#
#
#   更新紀錄：
#    Ver 1.00 ：
#    日期：2013.07.17
#    摘要：一、最初版本
#                 二、功能：合併兩個選項，製造高達八個選擇項
#
#    Ver 1.01
#    日期：2013.07.18
#    摘要：一、修改內建功能：將選項視窗移動到左邊
#
#    Ver 1.02
#    日期：2013.07.21
#    摘要：一、與另一個對話腳本"對話 - 立繪、圖像"合併作用
#                 二、完成暫停、存檔功能處理
#
#    Ver 1.03
#    日期：2013.07.21
#    摘要：一、調整回顧視窗的Z座標，使其在最上方
#                 二、回顧視窗的進去和取消都改用同一個鍵
#
#    撰寫摘要：一、此腳本修改或重新定義以下類別：
#                          1.Game_Interpreter
#                          2.Game_System
#                          3.Window_ChoiceList
#                          4.Scene_Map
#
#                          二、此腳本新定義以下類別：
#                          1.Sprite_PausePicture
#*******************************************************************************************


#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************



#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解釋器。
#   本類在 Game_Map、Game_Troop、Game_Event 類的內部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 方法重新定義
  #--------------------------------------------------------------------------
  unless $lctseng_alias_multi_choice
    alias lctseng_alias_multi_choice_Game_Interpreter_Clear clear # 清除
  end
  #--------------------------------------------------------------------------
  # ● 清除 - 重新定義
  #--------------------------------------------------------------------------
  def clear(*args,&block)
    lctseng_alias_multi_choice_Game_Interpreter_Clear(*args,&block)
    clear_keep_choice
  end
  #--------------------------------------------------------------------------
  # ● 設置選項 - 修改定義
  #--------------------------------------------------------------------------
  def setup_choices(params)
    puts "設置選項"
    @need_retore_choice = true # 提示解釋器要讀取選項答案
    if @skip_title[@indent]
      @skip_title[@indent] = false
      return
    end
    list = []
    if @need_more_choice[@indent]
      list = @choice_keep_list[@indent]
      @skip_title[@indent] = true
      @add_index[@indent] = params[0].size
      @need_more_choice[@indent] = false
      @pad_skip[@indent]  = params[0].size
    end
    (  params[0]  + list).each {|s| $game_message.choices.push(s) }
    $game_message.choice_cancel_type = params[1]
    $game_system.record_choice_indent(@indent)
    #$game_message.choice_proc = Proc.new {|n| @branch[@indent] = n } ## 原本使用安全的proc方式，移除
  end
  #--------------------------------------------------------------------------
  # ● [**] 的時候 - 修改定義
  #--------------------------------------------------------------------------
  def command_402
    ## 選項執行前，先把答案從$game_system讀取回來
    puts "準備執行選項結果檢查"
    check_choice_restore 
    
    ## 執行其他指令
    this_index = @params[0]
    if @index_pad_time[@indent] && @index_pad_time[@indent] > 0
      if @pad_skip[@indent] && @pad_skip[@indent] > 0
        @pad_skip[@indent] -= 1
      else
        @index_pad_time[@indent] -= 1
        this_index += @add_index[@indent]
      end
    end
    if @branch[@indent] != this_index
      command_skip
    end
  end
  #--------------------------------------------------------------------------
  # ● 要求保留選項
  #--------------------------------------------------------------------------
  def keep_choice(strings)
    clear_keep_choice
    @choice_keep_list[@indent] = strings
    @need_more_choice[@indent] = true
    @index_pad_time[@indent] = strings.size
  end
  #--------------------------------------------------------------------------
  # ● 清除保留選項
  #--------------------------------------------------------------------------
  def clear_keep_choice
    @choice_keep_list ={}
    @need_more_choice = {}
    @skip_title = {}
    @add_index = {}
    @index_pad_time = {}
    @pad_skip = {}
  end
  #--------------------------------------------------------------------------
  # ● 儲存實例 - 修改定義，儲存更多物件
  #    對纖程進行 Marshal 的自定義方法。
  #    此方法將事件的執行位置也一并保存起來。
  #--------------------------------------------------------------------------
  def marshal_dump
    puts "是否需要重讀選項：#{@need_retore_choice}"
    [@depth, @map_id, @event_id, @list, @index + 1 , @branch , @choice_keep_list , @need_more_choice , @skip_title , @add_index , @index_pad_time , @pad_skip , @need_retore_choice  ,@need_rooback]
  end
  #--------------------------------------------------------------------------
  # ● 讀取實例 - 修改定義，讀取更多物件
  #     obj : marshal_dump 中儲存的實例（數組）
  #    恢復多個數據（@depth、@map_id 等）的狀態，必要時重新創建纖程。
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch  ,@choice_keep_list , @need_more_choice , @skip_title , @add_index , @index_pad_time , @pad_skip , @need_retore_choice, @need_rooback  = obj
    puts "是否需要重讀選項：#{@need_retore_choice}"
    puts "索引倒退指數：#{@need_rooback}"
    #if $game_system.scene_rollback > 0 && @need_rooback
    if @need_rooback&&@need_rooback > 0
      puts "索引倒退，原本是：#{@index}，倒退：#{@need_rooback}"
      @index -= @need_rooback
      $game_system.scene_rollback = 0
    end
    create_fiber
  end
  #--------------------------------------------------------------------------
  # ● 檢查是否有選項結果需要讀取
  #--------------------------------------------------------------------------
  def check_choice_restore
    if @need_retore_choice
      puts "發現有結果存在"
      #@branch[$game_system.load_choice_indent] = $game_system.load_choice_result
      @branch[@indent] = $game_system.load_choice_result
      @need_retore_choice = false
    end
  end
  

end

#encoding:utf-8
#==============================================================================
# ■ Window_ChoiceList
#------------------------------------------------------------------------------
# 　此窗口使用于事件指令中的“顯示選項”的功能。
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● 方法重新定義
  #--------------------------------------------------------------------------
  unless $lctseng_alias_multi_choice
    alias lctseng_alias_multi_choice_Window_ChoiceList_Update_placement update_placement # 更新窗口的位置
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置 - 重新定義
  #--------------------------------------------------------------------------
  def update_placement(*args,&block)
    lctseng_alias_multi_choice_Window_ChoiceList_Update_placement(*args,&block)
    self.x = 0
  end
  #--------------------------------------------------------------------------
  # ● 調用“確定”的處理方法 - 修改定義，不執行Proc，改把答案存在$game_system
  #--------------------------------------------------------------------------
  def call_ok_handler
    puts "選擇答案：#{index}"
    $game_system.record_choice_result(index)
    #$game_message.choice_proc.call(index)
    close
  end
  #--------------------------------------------------------------------------
  # ● 調用“取消”的處理方法 - 修改定義，不執行Proc，改把答案存在$game_system
  #--------------------------------------------------------------------------
  def call_cancel_handler
    $game_system.record_choice_result($game_message.choice_cancel_type - 1)
    #$game_message.choice_proc.call($game_message.choice_cancel_type - 1)
    close
  end
  
  
end

#encoding:utf-8
#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　處理系統附屬數據的類。保存存檔和菜單的禁止狀態之類的數據。
#   本類的實例請參考 $game_system 。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 方法重新定義
  #--------------------------------------------------------------------------
  unless $lctseng_alias_multi_choice
    alias lctseng_alias_multi_choice_Game_System_Initialize initialize # 初始化對象
  end
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :message_pause
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  def initialize(*args,&block)
    lctseng_alias_multi_choice_Game_System_Initialize(*args,&block)
    clear_choice # 清除選項資料
    clear_message_pause_data # 清除暫停資料
  end
  #--------------------------------------------------------------------------
  # ● 清除選項資料
  #--------------------------------------------------------------------------
  def clear_choice
    @choice_data = {}
  end
  #--------------------------------------------------------------------------
  # ● 清除暫停資料
  #--------------------------------------------------------------------------
  def clear_message_pause_data
    @message_pause = false
  end
  #--------------------------------------------------------------------------
  # ● 紀錄選項的深度
  #--------------------------------------------------------------------------
  def record_choice_indent(indent)
    @choice_data[:indent] = indent
  end
  #--------------------------------------------------------------------------
  # ● 紀錄選項的結果
  #--------------------------------------------------------------------------
  def record_choice_result(result)
    @choice_data[:result] = result
  end
  #--------------------------------------------------------------------------
  # ● 讀取選項的結果
  #--------------------------------------------------------------------------
  def load_choice_result
    return @choice_data[:result]
  end
  #--------------------------------------------------------------------------
  # ● 讀取選項的深度
  #--------------------------------------------------------------------------
  def load_choice_indent
    return @choice_data[:branch]
  end
  #--------------------------------------------------------------------------
  # ● 檢查是否可以讀取結果
  #--------------------------------------------------------------------------
  def choice_result_ok?
    !@choice_data[:result].nil?
  end
  
end

#encoding:utf-8
#==============================================================================
# ■ Sprite_PausePicture
#      暫停文字圖片精靈
#==============================================================================

class Sprite_PausePicture < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Cache.system(Lctseng_Message_Face_Settings::Pause_Picture_File_Name)
    self.x = self.y = 0
    self.z = Lctseng_Message_Face_Settings::Pause_Picture_Z
    self.visible = false
  end
end

#encoding:utf-8
#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 　地圖畫面
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 方法重新定義
  #--------------------------------------------------------------------------
  unless $lctseng_alias_multi_choice
    alias lctseng_alias_multi_choice_Scene_Map_Start start # 開始
    alias lctseng_alias_multi_choice_Scene_Map_Update update # 更新畫面
    alias lctseng_alias_multi_choice_Scene_Map_Terminate terminate # 結束處理
  end
  #--------------------------------------------------------------------------
  # ● 開始 - 重新定義
  #--------------------------------------------------------------------------
  def start(*args,&block)
    lctseng_alias_multi_choice_Scene_Map_Start(*args,&block)
    create_pause_sprite
  end
  #--------------------------------------------------------------------------
  # ● 產生暫停精靈
  #--------------------------------------------------------------------------
  def create_pause_sprite
    @pause_sprite = Sprite_PausePicture.new
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update(*args,&block)
    lctseng_alias_multi_choice_Scene_Map_Update(*args,&block)
    update_check_pause
    update_check_save
  end
  #--------------------------------------------------------------------------
  # ● 監聽暫停
  #--------------------------------------------------------------------------
  def update_check_pause
    if Kboard.keyboard($R_Key_V)  && $game_message.busy?
      if $game_system.message_pause
        @pause_sprite.visible = false
        puts "要求復原"
        $game_system.message_pause = false
        restore_window_visible
      else
        @pause_sprite.visible = true
        puts "要求暫停"
        $game_system.message_pause = true
        record_window_visible
      end
      
    end
  end
  #--------------------------------------------------------------------------
  # ● 紀錄所有視窗的可視度
  #--------------------------------------------------------------------------
  def record_window_visible
    @visible_hash = {}
    if @message_window
      @message_window.record_window_visible
    end
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        ivar.update 
        @visible_hash[ivar] = ivar.visible
        ivar.visible = false
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 回復所有視窗的可視度
  #--------------------------------------------------------------------------
  def restore_window_visible
    return if !@visible_hash
    @visible_hash.each_pair do |window,visible|
      window.visible = visible
      window.update
    end
    if @message_window
      @message_window.restore_window_visible
    end
  end
  #--------------------------------------------------------------------------
  # ● 監聽存檔
  #--------------------------------------------------------------------------
  def update_check_save
    if Input.trigger?(:L) && !$game_system.save_disabled && $game_message.busy? && !$game_system.message_pause
      puts "要求進入存檔視窗"
      SceneManager.call(Scene_Save)
    end
  end
#--------------------------------------------------------------------------
  # ● 更新所有窗口，只在沒有暫停的時候更新窗口
  #--------------------------------------------------------------------------
  def update_all_windows
    if !$game_system.message_pause
      super
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 結束處理 - 重新定義
  #--------------------------------------------------------------------------
  def terminate(*args,&block)
    @pause_sprite.dispose
    lctseng_alias_multi_choice_Scene_Map_Terminate(*args,&block)
  end

  
end



#==============================================================================
# ■ $lctseng_alias_multi_choice
#------------------------------------------------------------------------------
# 　防止F12干擾腳本重新定義的保護標籤
#==============================================================================
$lctseng_alias_multi_choice = true

