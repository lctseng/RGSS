#encoding:utf-8

=begin
*******************************************************************************************

   ＊ Lctseng - 追加系統設定選單＊

                       for RGSS3

        Ver 1.00   2013.09.02

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
   
   需求前置腳本：Lctseng - 系統設定畫面
   請將此腳本至於該腳本底下
   
   
   主要功能：
                       一、將系統設定畫面添加到選單指令中

   更新紀錄：
    Ver 1.00 ：
    日期：2013.09.02
    摘要：一、最初版本



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.Scene_Menu 
                          2.Window_MenuCommand
                          
                          

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
## 檢查前置腳本
if !$lctseng_scripts[:system_option]
  msgbox("沒有發現前置腳本：Lctseng - 系統設定畫面\n或者是腳本位置錯誤！\n程式即將關閉")
  exit
end
$lctseng_scripts[:menu_system_option] = "1.00"

puts "載入腳本：Lctseng - 追加系統設定選單，版本：#{$lctseng_scripts[:menu_system_option]}"

#encoding:utf-8
#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　菜單畫面
#==============================================================================

class Scene_Menu 
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_system_option_on_Scene_Menu_alias
    alias lctseng_for_system_option_on_Scene_Menu_for_Create_command_window create_command_window # 生成指令窗口
    @lctseng_for_system_option_on_Scene_Menu_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 生成指令窗口 - 重新定義
  #--------------------------------------------------------------------------
  def create_command_window(*args,&block)
    lctseng_for_system_option_on_Scene_Menu_for_Create_command_window(*args,&block)
    @command_window.set_handler(:systemOption,    method(:command_system))
  end
  #--------------------------------------------------------------------------
  # ● 指令“系統”
  #--------------------------------------------------------------------------
  def command_system
    SceneManager.call(Scene_SystemOption)
  end

end


#encoding:utf-8
#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　菜單畫面中顯示指令的窗口
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_system_option_on_Window_MenuCommand_alias
    alias lctseng_for_system_option_on_Window_MenuCommand_for_Add_original_commands add_original_commands
    @lctseng_for_system_option_on_Window_MenuCommand_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 獨自添加指令用 - 重新定義
  #--------------------------------------------------------------------------
  def add_original_commands(*args,&block)
    lctseng_for_system_option_on_Window_MenuCommand_for_Add_original_commands(*args,&block)
    add_command("系統選項", :systemOption, true)
  end

end
