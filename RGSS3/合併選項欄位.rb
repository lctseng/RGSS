#encoding:utf-8

#*******************************************************************************************
#
#   ＊ 合併欄位選項 ＊
#
#                       for RGSS3
#
#        Ver 1.00   2013.07.17
#
#   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
#
#   轉載請保留此標籤
#
#   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
#
#   主要功能：
#                       一、合併兩個選項，製造高達八個選擇項
#
#
#   更新紀錄：
#    Ver 1.00 ：
#    日期：2013.07.17
#    摘要：一、最初版本
#                 二、功能：合併兩個選項，製造高達八個選擇項
#
#
#    撰寫摘要：一、此腳本修改或重新定義以下類別：
#                          1.Game_Interpreter
#
#
#*******************************************************************************************


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


$lctseng_scripts[:merge_choice] = "1.00"

puts "載入腳本：Lctseng - 合併選項欄位，版本：#{$lctseng_scripts[:merge_choice]}"




#encoding:utf-8
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
    $lctseng_alias_multi_choice = true
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
    $game_message.choice_proc = Proc.new {|n| @branch[@indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● [**] 的時候 - 修改定義
  #--------------------------------------------------------------------------
  def command_402
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
    [@depth, @map_id, @event_id, @list, @index + 1 , @branch , @choice_keep_list , @need_more_choice , @skip_title , @add_index , @index_pad_time , @pad_skip  ]
  end
  #--------------------------------------------------------------------------
  # ● 讀取實例 - 修改定義，讀取更多物件
  #     obj : marshal_dump 中儲存的實例（數組）
  #    恢復多個數據（@depth、@map_id 等）的狀態，必要時重新創建纖程。
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @depth, @map_id, @event_id, @list, @index, @branch  ,@choice_keep_list , @need_more_choice , @skip_title , @add_index , @index_pad_time , @pad_skip   = obj
    create_fiber
  end

end
