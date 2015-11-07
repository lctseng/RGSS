#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 擴散技能 ＊

                       for RGSS3

        Ver 1.0.0   2015.11.07

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原為替"asd181544257（猛將天馳）"撰寫的特製版本

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、特定技能可造成目標敵方與剩餘敵方不同的技能效果

   使用方法：
        將需要擁有擴散效果的技能註解中加入<Multi_Skill:擴散技能ID>
        即可讓目標以外的剩餘敵人受到擴散技能效果
        (目標本身並不會受影響，只會受到原本施放於目標的技能)


   注意事項：
        此腳本中直接改寫了Scene_Battle中的use_item方法，
        插入其他腳本時請注意相依性


   更新紀錄：
    Ver 1.0.0 ：
    日期：2015.11.07
    摘要：■、最初版本



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Scene_Battle



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
_sym = :extra_item_after_use_item
$lctseng_scripts[_sym] = "1.0.0"

puts "載入腳本：Lctseng - 擴散技能，版本：#{$lctseng_scripts[_sym]}"

#encoding:utf-8
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　戰斗畫面
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 使用技能／物品 (修改)
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.use_item(item)
    refresh_status
    targets = @subject.current_action.make_targets.compact
    if item.is_a?(RPG::Skill) && item.note =~ /<Multi_Skill:(\d+)>/i
      all_targets = @subject.current_action.opponents_unit.alive_members
      side_targets = all_targets - targets
      side_item = $data_skills[$1.to_i]
      show_animation_no_wait(targets, item.animation_id)
      show_animation(side_targets, side_item.animation_id)
      targets.each {|target| item.repeats.times { invoke_item(target, item) } }
      side_targets.each {|target| side_item.repeats.times { invoke_item(target, side_item) } }
    else
      show_animation(targets, item.animation_id)
      targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示動畫(不等待)
  #     targets      : 目標的數組
  #     animation_id : 動畫 ID（-1: 與普通攻擊一樣）
  #--------------------------------------------------------------------------
  def show_animation_no_wait(targets, animation_id)
    if animation_id < 0
      show_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
  end
end
