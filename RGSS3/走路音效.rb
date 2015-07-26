
#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 走路音效 ＊

                       for RGSS3

        Ver 1.0.0   2015.07.26

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123，Github ID：lctseng


   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
   RGSS Github：https://github.com/lctseng/RGSS
   本範例專案連結：https://drive.google.com/file/d/0B0HNBL2XSIayeTZSRGRvY0R2aTg/view?usp=sharing

   主要功能：
                       一、利用腳本的方式讓玩家角色走路可以有聲音

   更新紀錄：
    Ver 1.0.0 ：
    日期：2015.07.26
    摘要：■、最初版本




    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Game_CharacterBase
                           ■ Game_Player

                        二、此腳本提供設定模組
                           ■ Lctseng



*******************************************************************************************

=end
module Lctseng
  #--------------------------------------------------------------------------
  # ● 音效間隔，數值越大，發出聲音的間隔越長(最小為1)
  #--------------------------------------------------------------------------
  SE_INTERVAL = 1
  #--------------------------------------------------------------------------
  # ● 由區域ID取得音效
  # 這裡設置的音效請擺放在Audio/SE資料夾底下
  #--------------------------------------------------------------------------
  def self.get_step_se_by_region_id(r_id)
    f = nil
    case r_id
    when 12 # 草地
      f = ['Step_Grass','Step_Grass2'].sample # 多音效隨機
    when 13 # 地毯
      f = ['Step_Stone2','Step_Stone3'].sample
    when 14 # 磁磚
      f = 'Step_Tile'
    when 15 # 落葉
      f = 'Step_Leaf'
    when 16 #大廳
      f =  'Step_Hall'
    when 17 # 泥地
      f = 'Step_Mud'
    when 18 # 道路
      f = 'Step_Stone'
    when 19 # 木板
      f=  'Step_Wood'
    when 20 # 木橋
      f=  'Step_Wood2'
    when 21 # 鐵板
      f=  ['Step_Iron'].sample
    when 22 # 上樓梯
      f=  ['Step_Stone2','Step_Stone3'].sample
    end
    return f
  end
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

_script_sym = :step_se

$lctseng_scripts[_script_sym] = "1.0.0"

puts "載入腳本：Lctseng - 走路音效，版本：#{$lctseng_scripts[_script_sym]}"




class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 增加普通移動計數
  #--------------------------------------------------------------------------
  def add_move_count_normal(val = default_move_count)
    return if self.transparent # 透明時不顯示
    if !@normal_move_count
      @normal_move_count = 0
    end
    @normal_move_count += val
    if @normal_move_count >= step_se_play_count
      @normal_move_count = 0
      play_se_by_region_id(region_id)
    end

  end
  #--------------------------------------------------------------------------
  # ● 預設移動計數
  #--------------------------------------------------------------------------
  def default_move_count
    0
  end
  #--------------------------------------------------------------------------
  # ● 播放計數
  #--------------------------------------------------------------------------
  def step_se_play_count
    Lctseng::SE_INTERVAL
  end
  #--------------------------------------------------------------------------
  # ● 根據區域ID播放音效
  #--------------------------------------------------------------------------
  def play_se_by_region_id(r_id)
    f = Lctseng.get_step_se_by_region_id(r_id)
    puts "準備播放音效，區域ID：#{r_id}，檔案：#{f}" if $TEST
    RPG::SE.new(f,80).play if f
  end
  #--------------------------------------------------------------------------
  # ● 增加步數 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_step_se_on_Game_CharacterBase_for_Increase_steps increase_steps # 增加步數
  def increase_steps
    lctseng_step_se_on_Game_CharacterBase_for_Increase_steps
    add_move_count_normal
  end
end


class Game_Player
  #--------------------------------------------------------------------------
  # ● 預設移動計數
  #--------------------------------------------------------------------------
  def default_move_count
    1
  end
end
