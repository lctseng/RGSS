=begin


功能最後更新日期：2012.10.27

功能版本：0.11

2012.10.27功能版本0.11：編輯改良：新增簡易訪問法：變量完成度(Window_TaskDetails)

自定義的類別：
# ■Window_TaskDetails
# ■Window_Choose_Task
# ■Scene_TaskOverview

=end


=begin

存放：任務日誌

=end


class Game_Plus_Data
  #--------------------------------------------------------------------------
  # ● 系統常數
  #--------------------------------------------------------------------------
  TASK_Max_Task_Number  = 300
  #--------------------------------------------------------------------------
  # ● 實例變數
  #--------------------------------------------------------------------------
  attr_accessor :main_task_array
  #--------------------------------------------------------------------------
  # ● 初始化類別
  #--------------------------------------------------------------------------
  def initialize
    set_all_data
  end
  #--------------------------------------------------------------------------
  # ● 所有資料歸零
  #--------------------------------------------------------------------------
  def set_all_data
    set_task
  end
  #--------------------------------------------------------------------------
  # ● 補齊所有資料
  #--------------------------------------------------------------------------
  def patch_all_data
    set_task  unless @main_task_array
  end#end def
  #--------------------------------------------------------------------------
  # ● 重新建立：任務
  #--------------------------------------------------------------------------
  def set_task
    @main_task_array = Array.new(TASK_Max_Task_Number+1)
    for i in 1..TASK_Max_Task_Number
      @main_task_array[i]=[nil,false]
    end
  end
  #--------------------------------------------------------------------------
  # ● 任務日誌：開啟任務
  #--------------------------------------------------------------------------
  def task_get_task(id)
    @main_task_array[id][1] = true rescue return
  end
  #--------------------------------------------------------------------------
  # ● 任務日誌：關閉任務
  #--------------------------------------------------------------------------
  def task_finish_task(id)
    @main_task_array[id][1] = false rescue return
  end
end

#==============================================================================
# ■  DataManager
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # ● 生成存檔內容  - 重新定義
  #--------------------------------------------------------------------------
  class << self
    alias lctseng_for_main_task_Make_save_header make_save_header
  end
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player

    contents[:plus_data]  = $game_plus
    contents
  end
  #--------------------------------------------------------------------------
  # ● 展開存檔內容  - 重新定義
  #--------------------------------------------------------------------------
  class << self
    alias lctseng_for_main_task_Extract_save_contents extract_save_contents
  end
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    lctseng_for_main_task_Extract_save_contents(contents)
    $game_plus = contents[:plus_data]
 end
  #--------------------------------------------------------------------------
  # ● 設置新游戲  - 重新定義
  #--------------------------------------------------------------------------
  class << self
    alias lctseng_for_main_task_Setup_new_game setup_new_game
  end
  #--------------------------------------------------------------------------
  def self.setup_new_game
    create_game_plus_objects
    lctseng_for_main_task_Setup_new_game
  end
  #--------------------------------------------------------------------------
  # ● 產生額外遊戲物件包
  #--------------------------------------------------------------------------
  def self.create_game_plus_objects
    $game_plus = Game_Plus_Data.new
  end
end

=begin

選單中任務選項

=end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================


class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 開啟任務
  #--------------------------------------------------------------------------
  def get_task(id)
    $game_plus.task_get_task(id)
  end
  #--------------------------------------------------------------------------
  # ● 關閉任務
  #--------------------------------------------------------------------------
  def finish_task(id)
    $game_plus.task_finish_task(id)
  end
end##end class


#encoding:utf-8
#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　菜單畫面中顯示指令的窗口
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 獨自添加指令用 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_1st_new_menu_command_Add_original_commands add_original_commands
  #--------------------------------------------------------------------------
  def add_original_commands
    lctseng_for_1st_new_menu_command_Add_original_commands
    add_command("任務日誌",  :task)
  end
end

#encoding:utf-8
#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　菜單畫面
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 生成指令窗口 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_1st_new_menu_command_Create_command_window create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
    lctseng_for_1st_new_menu_command_Create_command_window
    @command_window.set_handler(:task,    method(:command_task))
  end
  #--------------------------------------------------------------------------
  # ● 新指令“任務日誌”
  #--------------------------------------------------------------------------
  def command_task
    SceneManager.call(Scene_TaskOverview)
  end
end

=begin
任務內容
=end

#==============================================================================
# ■ Window_TaskDetails
#==============================================================================


class Window_TaskDetails< Window_Base
  Next_line = 14
  LINE_HEIGHT_ADJUST = 10
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize          #初始化
    super(Graphics.width/2 - 50, 0, Graphics.width/2 + 50, Graphics.height)   #視窗大小（X座標, Y座標 , 寬度, 高度）
    @last_task = 0
    $game_plus.main_task_array[1][0] = "「拿書」行動"
    $game_plus.main_task_array[2][0] = "採藥草"
    $game_plus.main_task_array[3][0] = "意外的發現"
    $game_plus.main_task_array[4][0] = "到處逛逛"
    $game_plus.main_task_array[5][0] = "神秘的少女！"
    $game_plus.main_task_array[6][0] = "有扒手！"
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh(task_id)
    return if  @last_task == task_id
    @last_task = task_id
    @@x = 0  #第一個顯示文字的起始點X座標
    @@y = 0  #第一個顯示文字的起始點Y座標
    @@Add_line_used = 0
    self.contents.clear #清除目前視窗內容
    C(17)
    case task_id
      when 1
            Text("主線任務："+ $game_plus.main_task_array[task_id][0])
            C(0)
            Text("要運到圖書館的書又被盜走")
            Text("了，要趕緊把書搶回來。在")
            Text("這個地下基地裡，你必須打")
            Text("倒這層樓的所有敵人才能到")
            Text("達下一層。")
            var_finish_status(123 ,"打倒一層敵人：" ,8)
            var_finish_status(124 ,"打倒二層敵人：" ,8)
      when 2
            Text("主線任務："+ $game_plus.main_task_array[task_id][0])
            C(0)
            Text("為了要讓受害者們恢復意識")
            Text("，必須要許多藥草。到東興")
            Text("鎮北方的森林看看吧！")
            item_finish_status(3 , 1 , 8 )
            item_finish_status(3 , 2 , 8 )
            item_finish_status(3 , 3 , 8 )
            item_finish_status(3 , 4 , 8 )
            item_finish_status(3 , 5 , 8 )
            item_finish_status(3 , 6 , 8 )
            item_finish_status(3 , 7 , 1 )

   end##end case

 end##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：物品是否完成(1 = 武器 2 = 防具 3 = 道具)
  #--------------------------------------------------------------------------
  def item_finish_status(type , id , require )
    case type
    when 1
      if P_Weapon(id) >=  require
          C(3)
          Text(Weapon(id).name+"："+P_Weapon(id,true)+"/"+ require.to_s+"(完成)")
        else
          C(2)
          Text(Weapon(id).name+"："+P_Weapon(id,true)+"/"+ require.to_s)
        end
    when 2
      if P_Armor(id) >=  require
          C(3)
          Text(Armor(id).name+"："+P_Armor(id,true)+"/"+ require.to_s+"(完成)")
        else
          C(2)
          Text(Armor(id).name+"："+P_Armor(id,true)+"/"+ require.to_s)
        end
    when 3
      if P_Item(id) >=  require
          C(3)
          Text(Item(id).name+"："+P_Item(id,true)+"/"+ require.to_s+"(完成)")
        else
          C(2)
          Text(Item(id).name+"："+P_Item(id,true)+"/"+ require.to_s)
        end
    end ##end case
  end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：變量是否足夠
  #       string : 說明文字
  #--------------------------------------------------------------------------
  def var_finish_status(mission_var_id , string ,require)
    if Var(mission_var_id) >=  require
      C(3)
      Text(string+Var(mission_var_id,true)+"/"+require.to_s+"(完成)")
    else
      C(2)
      Text(string+Var(mission_var_id,true)+"/"+require.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：文字串
  #--------------------------------------------------------------------------

    def Text(text)
      self.contents.draw_text(@@x,   line_height*(@@Add_line_used), Graphics.width/2 +50 ,  line_height+ LINE_HEIGHT_ADJUST  , text) #繪製文字，
      @@Add_line_used +=1
      next_line? #換行判定
    end ##end\ def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：是否換行？
  #--------------------------------------------------------------------------
    def next_line?
      if @@Add_line_used>=Next_line
        @@x +=  180  #即將換行，X座標右移
        @@Add_line_used = 0  #佔用行數重置
      end
    end
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：道具
  #--------------------------------------------------------------------------
    def Item(id)
      return $data_items[id]
    end
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：防具
  #--------------------------------------------------------------------------
    def Armor(id)
      return $data_armors[id]
    end
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：武器
  #--------------------------------------------------------------------------
    def Weapon(id)
      return $data_weapons[id]
    end
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的道具數量
  #--------------------------------------------------------------------------

    def P_Item(id,string = false)
      return $game_party.item_number($data_items[id]).to_s if string == true
      return $game_party.item_number($data_items[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的防具數量
  #--------------------------------------------------------------------------

    def P_Armor(id,string = false)
      return $game_party.item_number($data_armors[id]).to_s if string == true
      return $game_party.item_number($data_armors[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的武器數量
  #--------------------------------------------------------------------------

    def P_Weapon(id,string = false)
      return $game_party.item_number($data_weapons[id]).to_s if string == true
      return $game_party.item_number($data_weapons[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的金錢數量
  #--------------------------------------------------------------------------
    def p_Gold(string = false)
       return $game_party.gold.to_s if string == true
       return $game_party.gold
     end ##end def

  #--------------------------------------------------------------------------
  # ● 簡單訪問法：變量
  #--------------------------------------------------------------------------
     def Var(id,string = false)
       return $game_variables[id].to_s  if string == true

       return $game_variables[id]
     end

  #--------------------------------------------------------------------------
  # ● 簡單訪問法：改變字體顏色
  #--------------------------------------------------------------------------
     def C(id)
       self.contents.font.color = text_color(id)
      end ##end def
    end

#==============================================================================
# ■ Window_Choose_Task
#==============================================================================

class Window_Choose_Task < Window_Command

  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(x = 0,y=0)
    super(x, y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 獲取窗口的寬度
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width/2 - 50
  end
    def window_height
    Graphics.height
  end

  #--------------------------------------------------------------------------
  # ● 獲取列數
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    for i in 1...Game_Plus_Data::TASK_Max_Task_Number
      add_command($game_plus.main_task_array[i][0],    i.to_s.to_sym)     if $game_plus.main_task_array[i][1]
    end
  end
end


#==============================================================================
# ■ Scene_TaskOverview
#==============================================================================
class Scene_TaskOverview< Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始
  #--------------------------------------------------------------------------
  def start                               #開始
    super  #繼承父類別建構式
    create_background   #創建選單背景
    @Details = Window_TaskDetails.new
    @Choose  =  Window_Choose_Task.new
  end
  #--------------------------------------------------------------------------
  # ● 終止
  #--------------------------------------------------------------------------
  def terminate  #改寫結束函式
    super #繼承父類別結束函式
    @Choose.dispose   #清除視窗
    @Details.dispose

  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update  #更新
    super
    if Input.trigger?(Input::B)    #按下B鍵
      Sound.play_cancel         #播放關閉的聲音
      return_scene              #返回選單
    end
    sym = @Choose.current_symbol
    if sym
      str = sym.id2name
      str = str.to_i
      @Details.refresh(str)
    end

  end
  #--------------------------------------------------------------------------
  # ● 返回選單
  #--------------------------------------------------------------------------
  def return_scene              #返回選單
    SceneManager.return #呼叫內建功能
  end
end
