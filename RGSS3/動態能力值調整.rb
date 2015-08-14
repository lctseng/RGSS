#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 動態增減附加能力與特殊能力 ＊

                       for RGSS3

        Ver 1.0.0   2014.02.05

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   替"fzz(500)"撰寫的特製版本


   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、動態增減角色的附加能力(Xparam)與特殊能力(Sparam)
                       二、可清除該角色由此腳本所添加的所有能力

   ★ 使用說明：
   一、調整"附加能力(Xparam)"
           可調整角色的：命中率、迴避率、暴擊率、迴避暴擊率、魔法閃避、魔法反射、反擊率、HP MP TP的再生率等等
           兼顧可讀性，有兩種呼叫方式，分別是百分比與浮點數(實數)

      1. 百分比：在事件中使用腳本呼叫：add_xparam_percent(角色ID , 能力編號 , 百分數值)
                         例如：add_xparam_percent(9,0,-100)
                         即代表：角色9的命中率減少100%

      2. 浮點數：在事件中使用腳本呼叫：add_xparam(角色ID , 能力編號 , 浮點數數值)
                         例如：add_xparam(9,2,0.8)
                         即代表：角色9的暴擊率增加0.8(即80%)

      3. 關於能力ID與附加能力(Xparam)的對照表，以下列出：
               附加能力ID：0    # 命中率        HIT rate
               附加能力ID：1    # 迴避率        EVAsion rate
               附加能力ID：2    # 暴擊率        CRItical rate
               附加能力ID：3    # 閃避暴擊機率    Critical EVasion rate
               附加能力ID：4    # 閃避魔法機率    Magic EVasion rate
               附加能力ID：5    # 反射魔法機率    Magic ReFlection rate
               附加能力ID：6    # 反擊機率        CouNTer attack rate
               附加能力ID：7    # HP再生速度      Hp ReGeneration rate
               附加能力ID：8    # MP再生速度      Mp ReGeneration rate
               附加能力ID：9    # TP再生速度      Tp ReGeneration rate

   二、調整"特殊能力(Sparam)"
           可調整角色的：物理傷害率、魔法傷害率等等
           與上述"附加能力(Xparam)"差不多，兼顧可讀性，也有兩種呼叫方式，不再贅述

      1. 此特殊能力調整與狀態中設定有些許不同，
          例如想讓角色受到的物理傷害率減少為80%，需如此設定：
          add_sparam_percent(9,6,-20) 或 add_sparam(9,6,-0.2)
          如果同時有兩次呼叫，則效果疊加，亦即變成減少為60%(-20%重複兩次)，最低結果為變成0%(減少100%)

      2. 關於能力ID與特殊能力(Sparam)的對照表，以下列出：
               特殊能力ID：0    # 受到攻擊的幾率        TarGet Rate
               特殊能力ID：1    # 防御效果比率    GuaRD effect rate
               特殊能力ID：2    # 恢復效果比率    RECovery effect rate
               特殊能力ID：3    # 藥理知識        PHArmacology
               特殊能力ID：4    # MP消費率        Mp Cost Rate
               特殊能力ID：5    # TP消耗率        Tp Charge Rate
               特殊能力ID：6    # 受到的物理傷害加成    Physical Damage Rate
               特殊能力ID：7    # 受到的魔法傷害加成    Magical Damage Rate
               特殊能力ID：8    # 地形傷害加成    Floor Damage Rate
               特殊能力ID：9    # 經驗獲得加成    EXperience Rate

   三、清除由此腳本產生出的能力影響(注意，不影響原本狀態或裝備的添加值)

      1. 清除附加能力：clear_xparam(角色ID,能力編號)
          例如：clear_xparam(9,2)，即清除9號角色的暴擊率改變

      2. 清除特殊能力的方法與之差不多，
          例如：clear_sparam(9,6)，即清除9號角色的物理傷害率改變

      3. 若能力ID指定為負數，則代表清除該角色的所有附加能力或特殊能力加成
          例如：clear_xparam(9,-1)，清除9號角色的所有附加能力變化
          例如：clear_sparam(9,-1)，清除9號角色的所有特殊能力變化

   更新紀錄：
    Ver 1.00 ：
    日期：2014.02.05
    摘要：■、最初版本
                ■、功能：
                       一、動態增減角色的附加能力(Xparam)與特殊能力(Sparam)
                       二、可清除該角色由此腳本所添加的所有能力



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Game_BattlerBase
                           ■ Game_Interpreter


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
$lctseng_scripts[:dynamic_param_adjust] = "1.0.0"

puts "載入腳本：Lctseng - 動態增減附加能力與特殊能力，版本：#{$lctseng_scripts[:dynamic_param_adjust]}"


#encoding:utf-8
#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　管理戰鬥者的類。主要含有能力值計算的方法。Game_Battler 類的父類。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_dynamic_param_on_Game_BattlerBase_alias
    alias lctseng_for_dynamic_param_on_Game_BattlerBase_for_Clear_param_plus clear_param_plus # 清除能力的增加值
    alias lctseng_for_dynamic_param_on_Game_BattlerBase_for_Xparam xparam # 獲取添加能力
    alias lctseng_for_dynamic_param_on_Game_BattlerBase_for_Sparam sparam # 獲取特殊能力
    @lctseng_for_dynamic_param_on_Game_BattlerBase_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 清除能力的增加值 - 重新定義
  #--------------------------------------------------------------------------
  def clear_param_plus(*args,&block)
    clear_xparam_plus
    clear_sparam_plus
    lctseng_for_dynamic_param_on_Game_BattlerBase_for_Clear_param_plus(*args,&block)
  end
  #--------------------------------------------------------------------------
  # ● 清除"添加能力"的增加值
  #--------------------------------------------------------------------------
  def clear_xparam_plus
    @xparam_plus = [0.0] * 10
  end
  #--------------------------------------------------------------------------
  # ● 清除"特殊能力"的增加值
  #--------------------------------------------------------------------------
  def clear_sparam_plus
    @sparam_plus = [1.0] * 10
  end
  #--------------------------------------------------------------------------
  # ● 清除"添加能力"的增加值，指定ID
  #--------------------------------------------------------------------------
  def clear_xparam(param_id)
    @xparam_plus[param_id] = 0.0
  end
  #--------------------------------------------------------------------------
  # ● 清除"特殊能力"的增加值，指定ID
  #--------------------------------------------------------------------------
  def clear_sparam(param_id)
    @sparam_plus[param_id] = 1.0
  end
  #--------------------------------------------------------------------------
  # ● 取得"添加能力"的增加值
  #--------------------------------------------------------------------------
  def xparam_plus(param_id)
    @xparam_plus[param_id]
  end
  #--------------------------------------------------------------------------
  # ● 取得"特殊能力"的增加值
  #--------------------------------------------------------------------------
  def sparam_plus(param_id)
    value = @sparam_plus[param_id]
    if value < 0.0
      value = 0.0
    end
    value
  end
  #--------------------------------------------------------------------------
  # ● 獲取"添加能力" - 重新定義
  #--------------------------------------------------------------------------
  def xparam(xparam_id)
    lctseng_for_dynamic_param_on_Game_BattlerBase_for_Xparam(xparam_id) + xparam_plus(xparam_id)
  end
  #--------------------------------------------------------------------------
  # ● 增加"添加能力"
  #   percent : 是否為百分比表示法
  #--------------------------------------------------------------------------
  def add_xparam(param_id, value , percent = false)
    r_value = value
    if percent
      r_value = r_value / 100.0
    end
    @xparam_plus[param_id] += r_value
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 獲取"特殊能力" - 重新定義
  #--------------------------------------------------------------------------
  def sparam(sparam_id)
    lctseng_for_dynamic_param_on_Game_BattlerBase_for_Sparam(sparam_id) * sparam_plus(sparam_id)
  end
  #--------------------------------------------------------------------------
  # ● 增加"特殊能力"
  #   percent : 是否為百分比表示法
  #--------------------------------------------------------------------------
  def add_sparam(param_id, value , percent = false)
    r_value = value
    if percent
      r_value = r_value / 100.0
    end
    @sparam_plus[param_id] += r_value
    refresh
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
  # ● 清除"添加能力"，id為負代表全部清除
  #--------------------------------------------------------------------------
  def clear_xparam(actor_id,param_id)
    actor = $game_actors[actor_id]
    if actor
      if param_id < 0
        actor.clear_xparam_plus
      else
        actor.clear_xparam(param_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除"特殊能力"，id為負代表全部清除
  #--------------------------------------------------------------------------
  def clear_sparam(actor_id,param_id)
    actor = $game_actors[actor_id]
    if actor
      if param_id < 0
        actor.clear_sparam_plus
      else
        actor.clear_sparam(param_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加"添加能力"，採實數
  #--------------------------------------------------------------------------
  def add_xparam(actor_id,param_id,value)
    actor = $game_actors[actor_id]
    if actor
      actor.add_xparam(param_id,value,false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加"添加能力"，採百分比
  #--------------------------------------------------------------------------
  def add_xparam_percent(actor_id,param_id,value)
    actor = $game_actors[actor_id]
    if actor
      actor.add_xparam(param_id,value,true)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加"特殊能力"，採實數
  #--------------------------------------------------------------------------
  def add_sparam(actor_id,param_id,value)
    actor = $game_actors[actor_id]
    if actor
      actor.add_sparam(param_id,value,false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加"特殊能力"，採百分比
  #--------------------------------------------------------------------------
  def add_sparam_percent(actor_id,param_id,value)
    actor = $game_actors[actor_id]
    if actor
      actor.add_sparam(param_id,value,true)
    end
  end
end
