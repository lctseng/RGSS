#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 物品快速判斷、扣除 ＊

                       for RGSS3

        Ver 1.10   2015.07.04

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123



   主要功能：
                       一、可以快速判斷是否完成物品數的任務，且提供道具扣除功能




    使用方法為：
    一、
      在判斷是否完成的條件分歧之前，先使用下列腳本指令：
      #----------分隔線----------

      enter_task_require(1 , 1 , 3)
      enter_task_require(2 , 2 , 2)
      enter_task_require(3 , 3 , 1)
      #...(以此類推)

      #----------分隔線----------
      enter_task_require後方的三個數字分別為：道具種類、道具ID、道具所需數量，
      0 = 金錢  1 = 武器 2 = 防具 3 = 物品
    二、
      在進行判斷時的條件分歧，請點選腳本，並填入下列指令：
      #----------分隔線----------

      run_task_judge(true) ##執行判斷並回傳結果至呼叫端，成功通過時扣除道具

      #或者是

      run_task_judge(false) ##執行判斷並回傳結果至呼叫端，成功通過時"不會"扣除道具

       #或者是

      run_task_judge ##執行判斷並回傳結果至呼叫端，成功通過時"不會"扣除道具(功能同上一個)

      #----------分隔線----------
    三、
      請注意，每次執行run_task_judge之後，
      之前所輸入的enter_task_require指令將會被完全清空，需要重新輸入，
      這地方確保使用者不會誤用上次的任務條件


    具體範例請參考地圖上的範例事件



    附註：
      重新定義的類別方法：Game_Interpreter -> initialize
      欲使用多重腳本時，請小心使用。進階使用者可以自行做相容的動作。




   更新紀錄：
    Ver 1.00 ：
    日期：2012.09.04
    摘要：一、最初版本

    Ver 1.10 ：
    日期：2015.07.04
    摘要：一、修正無法跨存檔的問題




    撰寫摘要：一、此腳本修改或重新定義以下類別：
                          1.Game_Interpreter
                          2.Game_System




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
$lctseng_scripts[:item_cost] = "1.10"

puts "載入腳本：Lctseng - 物品快速判斷、扣除，版本：#{$lctseng_scripts[:item_cost]}"







##=======================以下為程式碼=====================

#∥---------------------------------------------------------------------------------------------------------------------------------------
#∥▼ 物品快速判斷、扣除
#∥---------------------------------------------------------------------------------------------------------------------------------------

class Game_System
  #--------------------------------------------------------------------------
  # ● 讀取陣列
  #--------------------------------------------------------------------------
  def check_task_item_array
    @check_task_item_array ||= []
  end
  #--------------------------------------------------------------------------
  # ● 設置陣列
  #--------------------------------------------------------------------------
  def check_task_item_array=(val)
    @check_task_item_array = val
  end

end


class Game_Interpreter

  attr_accessor :check_task_item_array #檢視任務是否完成的陣列
  #--------------------------------------------------------------------------
  # ★類別方法重新定義
  #--------------------------------------------------------------------------
  alias henry_initialize initialize
  #--------------------------------------------------------------------------
  # ● 初始化對象-重新定義
  #     depth : 堆置深度
  #--------------------------------------------------------------------------
  def initialize(depth = 0)
    henry_initialize(depth = 0)
    self.check_task_item_array = []
  end
  #--------------------------------------------------------------------------
  # ● 取得陣列
  #--------------------------------------------------------------------------
  def check_task_item_array
    $game_system.check_task_item_array
  end
  #--------------------------------------------------------------------------
  # ● 設置陣列
  #--------------------------------------------------------------------------
  def check_task_item_array=(val)
    $game_system.check_task_item_array = val
  end
  #--------------------------------------------------------------------------
  # ● 輸入條件 0 = 金錢  1 = 武器 2 = 防具 3 = 物品
  #--------------------------------------------------------------------------
  def enter_task_require(type , id , number)
    self.check_task_item_array.push([type,id,number])
  end
  #--------------------------------------------------------------------------
  # ● 執行判斷並回傳結果至呼叫端
  #       cost : 是否自動扣除
  #--------------------------------------------------------------------------
  def run_task_judge(cost = false)
    for i in 0...(self.check_task_item_array).size
      type = self.check_task_item_array[i][0]
      id = self.check_task_item_array[i][1]
      n = self.check_task_item_array[i][2]
      case type
      when 0
        if p_Gold < n
          end_judgement
          return false
        end##end if
      when 1
        if P_Weapon(id) < n
          end_judgement
          return false
        end##end if
      when 2
        if P_Armor(id) < n
          end_judgement
          return false
        end##end if
      when 3
        if P_Item(id) < n
          end_judgement
          return false
        end##end if
      end##end case
    end##end for
    execute_cost if cost
    end_judgement
    return true
  end##end def
  #--------------------------------------------------------------------------
  # ● 扣除物品
  #--------------------------------------------------------------------------
  def execute_cost
    for i in 0...(self.check_task_item_array).size
      type = self.check_task_item_array[i][0]
      id = self.check_task_item_array[i][1]
      n = self.check_task_item_array[i][2]
      case type
      when 0
        $game_party.lose_gold(n)
      when 1
        $game_party.lose_item(Weapon(id),n)
      when 2
        $game_party.lose_item(Armor(id),n)
      when 3
        $game_party.lose_item(Item(id),n)
      end##end case
    end##end for

  end

  #--------------------------------------------------------------------------
  # ● 結束判斷時，清除
  #--------------------------------------------------------------------------
  def end_judgement
    self.check_task_item_array = []
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
      return $game_party.item_number($data_items[id]).to_s if string
      return $game_party.item_number($data_items[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的防具數量
  #--------------------------------------------------------------------------

    def P_Armor(id,string = false)
      return $game_party.item_number($data_armors[id]).to_s if string
      return $game_party.item_number($data_armors[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的武器數量
  #--------------------------------------------------------------------------

    def P_Weapon(id,string = false)
      return $game_party.item_number($data_weapons[id]).to_s if string
      return $game_party.item_number($data_weapons[id])
    end ##end def
  #--------------------------------------------------------------------------
  # ● 簡單訪問法：持有的金錢數量
  #--------------------------------------------------------------------------
    def p_Gold(string = false)
       return $game_party.gold.to_s if string
       return $game_party.gold
     end ##end def

  #--------------------------------------------------------------------------
  # ● 簡單訪問法：變量
  #--------------------------------------------------------------------------
     def Var(id,string = false)
       return $game_variables[id].to_s  if string
       return $game_variables[id]
     end


end
