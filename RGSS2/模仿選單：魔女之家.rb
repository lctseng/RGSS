#*******************************************************************************************
#
#   ＊ 簡化選單 - 魔女之家 ＊
#
#                       for RGSS2
#
#        Ver 1.00   2014.02.13
#
#   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
#
#   轉載請保留此標籤
#
#   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
#
#   主要功能：
#            一、與魔女之家相仿的選單
#
#
#   更新紀錄：
#    Ver 1.00 ：
#    日期：2014.02.13
#    摘要：一、最初版本
#         二、與魔女之家相仿的選單
#
#
#
#    撰寫摘要：
#             一、此腳本修改或重新定義以下類別：
#                1.Scene_Menu
#                2.Scene_File
#                3.Scene_End
#                4.Window_MenuStatus
#
#*******************************************************************************************


#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************


#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　處理菜單畫面的類。
#==============================================================================

class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始處理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    @gold_window = Window_Gold.new(0, 360)
    @gold_window.visible = false
    @status_window = Window_MenuStatus.new(160, 0)
    @status_window.y = Graphics.height - @status_window.height
    @command_window.y = Graphics.height - @status_window.height + (@status_window.height - @command_window.height ) / 2
  end
  #--------------------------------------------------------------------------
  # ● 生成命令窗口
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::item
    s5 = Vocab::save
        s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s5 , s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0          # 如果隊伍為空
      @command_window.draw_item(0, false)     # 無效化物品選項
    end
    if $game_system.save_disabled             # 如果禁止存檔
      @command_window.draw_item(1, false)     # 無效化存檔選項
    end
    
    
    
  end
  #--------------------------------------------------------------------------
  # ● 更新命令窗口
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 1
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 1
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0      # 物品
        $scene = Scene_Item.new
      when 1      # 存檔
        $scene = Scene_File.new(true, false, false)
      when 2      # 結束遊戲
        $scene = Scene_End.new
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色選擇更新
  #--------------------------------------------------------------------------
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
    end
  end
end

#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　存檔畫面及讀檔畫面的類。
#==============================================================================

class Scene_File < Scene_Base
  #--------------------------------------------------------------------------
  # ● 回到原畫面
  #--------------------------------------------------------------------------
  def return_scene
    if @from_title
      $scene = Scene_Title.new
    elsif @from_event
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(1)
    end
  end
end

#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 　處理遊戲結束畫面的類。
#==============================================================================

class Scene_End < Scene_Base

  #--------------------------------------------------------------------------
  # ● 回到原畫面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(2)
  end
end

#==============================================================================
# ■ Window_MenuStatus
#------------------------------------------------------------------------------
# 　顯示菜單畫面和同伴狀態的窗口。
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @item_max = $game_party.members.size
    for actor in $game_party.members
      draw_actor_face(actor, 2, actor.index * 96 + 2, 92)
      x = 104
      y = actor.index * 96 + WLH / 2
      draw_actor_name(actor, x, y)
      draw_actor_class(actor, x + 120, y)
      draw_actor_level(actor, x, y + WLH * 1)
      draw_actor_state(actor, x, y + WLH * 2)
      draw_actor_hp(actor, x + 120, y + WLH * 1)
    end
  end
end
