#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 施展技能/使用到具後附加額外技能/道具 ＊

                       for RGSS3

        Ver 1.0.0   2014.01.26

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123


   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、特定技能使用後，可對自身、敵人全體、我方全體、我方全體除了自己、全體角色除了自己，使用額外技能或道具(可附加狀態之類的)


   更新紀錄：
    Ver 1.0.0 ：
    日期：2014.01.26
    摘要：■、最初版本
                ■、功能：
                       一、特定技能使用後，可對自身、敵人全體、我方全體、我方全體除了自己、全體角色除了自己，使用額外技能或道具(可附加狀態之類的)



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Scene_Battle

                        二、此腳本新定義以下類別和模組：
                           ■ Lctseng::Extra_Item_Use


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
$lctseng_scripts[:extra_item_after_use_item] = "1.0.0"

puts "載入腳本：Lctseng - 施展技能/使用到具後附加額外技能/道具，版本：#{$lctseng_scripts[:extra_item_after_use_item]}"

#encoding:utf-8
#==============================================================================
# ■ Lctseng::Extra_Item_Use
#------------------------------------------------------------------------------
# 　額外道具設定模組
#==============================================================================

module Lctseng
module Extra_Item_Use
 #--------------------------------------------------------------------------
  # ● 設定：是否顯示Console 紀錄
  #--------------------------------------------------------------------------
  Show_Console_Info = true
  #--------------------------------------------------------------------------
  # ● 匹配用正規表達式：類型(0道具，1技能)，ID、機率、對象(0自身、1敵方全，2我方全，3全體，4我方除了自己，5全體除了自己)
  #--------------------------------------------------------------------------
  Regexp = /<Extra_Item_Use:(\d+),(\d+),(\d+),(\d+)>/i
  #--------------------------------------------------------------------------
  # ● 匹配額外道具資料
  #--------------------------------------------------------------------------
  def self.match_extra_item(item)
    list = []
    temp_note = item.note.clone
    while result = temp_note[Regexp]
      puts "while迴圈運行中，位置：匹配額外道具資料" if Show_Console_Info
      data = {}
      data[:type] = $1.to_i
      data[:id] = $2.to_i
      data[:rate] = $3.to_i
      data[:target] = $4.to_i
      list.push(interprete_data(data))
      temp_note[result] = ''
    end
    list
  end
  #--------------------------------------------------------------------------
  # ● 解譯匹配的原始資料
  #--------------------------------------------------------------------------
  def self.interprete_data(old_data)
    data = {}
    case old_data[:type]
    when 0
      target_data = $data_items
    when 1
      target_data = $data_skills
    end
    data[:item] = target_data[old_data[:id]]
    data[:rate] = old_data[:rate] / 100.0
    data[:target] = old_data[:target]
    data
  end
  #--------------------------------------------------------------------------
  # ● 由類型及自身類別取得目標清單
  #--------------------------------------------------------------------------
  def self.get_target_list(user,target_type)
    friend = user.friends_unit.members
    opponent = user.opponents_unit.members
    list = []
    case target_type
    when 0
      list.push(user)
    when 1
      opponent.each do |unit|
        list.push(unit)
      end
    when 2
      friend.each do |unit|
        list.push(unit)
      end
    when 3
      opponent.each do |unit|
        list.push(unit)
      end
      friend.each do |unit|
        list.push(unit)
      end
    when 4
      friend.each do |unit|
        next if unit == user
        list.push(unit)
      end
    when 5
      friend.each do |unit|
        next if unit == user
        list.push(unit)
      end
      opponent.each do |unit|
        list.push(unit)
      end
    end
    list
  end

end
end


#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　戰斗畫面
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_extra_item_use_on_Scene_Battle_alias
    alias lctseng_for_extra_item_use_on_Scene_Battle_for_Use_item use_item
    @lctseng_for_extra_item_use_on_Scene_Battle_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 使用技能／物品  - 重新定義
  #--------------------------------------------------------------------------
  def use_item(*args,&block)
    item = @subject.current_action.item
    lctseng_for_extra_item_use_on_Scene_Battle_for_Use_item(*args,&block)
    process_extra_item_use(@subject,item)
  end
  #--------------------------------------------------------------------------
  # ● 處理額外道具
  #--------------------------------------------------------------------------
  def process_extra_item_use(user,old_item)
    list = Lctseng::Extra_Item_Use.match_extra_item(old_item)
    list.each do |data|
      process_extra_item_data(user,data)
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理額外道具資料
  #--------------------------------------------------------------------------
  def process_extra_item_data(user,data)
    targets = Lctseng::Extra_Item_Use.get_target_list(user,data[:target])
    targets.each do |target|
      puts "嘗試以#{(data[:rate]*100).round}%的機率對#{target.name}使用#{data[:item].name}" if Lctseng::Extra_Item_Use::Show_Console_Info
      if rand < data[:rate]
        puts "成功對#{target.name}施放#{data[:item].name}！"if  Lctseng::Extra_Item_Use::Show_Console_Info
        item = data[:item]
        show_animation([target], item.animation_id)
        item.repeats.times { invoke_item(target, item) }
      end
    end
  end
end
