#encoding:utf-8

=begin
*******************************************************************************************

   ＊ ARPG傷害數字 ＊

                       for RGSS3

        Ver 1.00   2013.03.31

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、顯示ARPG用的傷害數字，詳細範例請見小屋中的專案
                       

   更新紀錄：
    Ver 1.00 ：
    日期：2013.03.31
    摘要：■、最初版本
                ■、功能：                  
                       一、顯示ARPG用的傷害數字，詳細範例請見小屋中的專案



    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Game_System
                           ■ Game_Interpreter
                           ■ Scene_Map
                          
                        二、此腳本新定義以下類別和模組：
                           ■ Lctseng_Arpg_Damage_Number_Store_Settings
                           ■ Game_ArpgDamageNumberCollecter
                           ■ Sprite_ArpgDamageNumber
                           ■ Sprite_EnemyDamageNumber
                           ■ Sprite_PlayerDamageNumber
                           ■ Sprite_ExpNumber
                           
                          
                        三、可供設定用的模組：
                           ■ Lctseng_Arpg_Damage_Number_Settings
                           
                           
*******************************************************************************************

=end


module Lctseng_Arpg_Damage_Number_Settings
  #--------------------------------------------------------------------------
  # ● 數字指定變數
  #--------------------------------------------------------------------------
  Number_Assign_Variable_ID_List = [5,6]
  #--------------------------------------------------------------------------
  # ● 字型設定
  #--------------------------------------------------------------------------
  ## 敵人傷害數字
  Enemy_Draw_Font = Font.new 
  Enemy_Draw_Font.name = 'Microsoft JhengHei' #字體名稱
  Enemy_Draw_Font.size = 24 #字體大小
  Enemy_Draw_Font.color = (Color.new(255,222,38,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Enemy_Draw_Font.bold = true #是否粗體字
  Enemy_Draw_Font.italic = true #是否斜體字
  Enemy_Draw_Font.outline = true #是否繪製文字邊緣
  Enemy_Draw_Font.shadow = true #是否繪製陰影
  Enemy_Draw_Font.out_color = (Color.new(100,100,100,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)

  ## 我方傷害數字
  Player_Draw_Font = Font.new 
  Player_Draw_Font.name = 'Microsoft JhengHei' #字體名稱
  Player_Draw_Font.size = 24 #字體大小
  Player_Draw_Font.color = (Color.new(255,0,0,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Player_Draw_Font.bold = true #是否粗體字
  Player_Draw_Font.italic = true #是否斜體字
  Player_Draw_Font.outline = true #是否繪製文字邊緣
  Player_Draw_Font.shadow = true #是否繪製陰影
  Player_Draw_Font.out_color = (Color.new(100,100,100,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)
  
  ## HP恢復數字
  Font_Recovery_Hp = Font.new 
  Font_Recovery_Hp.name = 'Microsoft JhengHei' #字體名稱
  Font_Recovery_Hp.size = 24 #字體大小
  Font_Recovery_Hp.color = (Color.new(0,204,0,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Font_Recovery_Hp.bold = true #是否粗體字
  Font_Recovery_Hp.italic = true #是否斜體字
  Font_Recovery_Hp.outline = true #是否繪製文字邊緣
  Font_Recovery_Hp.shadow = true #是否繪製陰影
  Font_Recovery_Hp.out_color = (Color.new(0,147,0,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)

  ## MP恢復數字
  Font_Recovery_Mp = Font.new 
  Font_Recovery_Mp.name = 'Microsoft JhengHei' #字體名稱
  Font_Recovery_Mp.size = 24 #字體大小
  Font_Recovery_Mp.color = (Color.new(0,166,254,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Font_Recovery_Mp.bold = true #是否粗體字
  Font_Recovery_Mp.italic = true #是否斜體字
  Font_Recovery_Mp.outline = true #是否繪製文字邊緣
  Font_Recovery_Mp.shadow = true #是否繪製陰影
  Font_Recovery_Mp.out_color = (Color.new(0,0,230,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)
  
  ## 經驗值數字
  Font_Exp_Gain = Font.new 
  Font_Exp_Gain.name = 'Microsoft JhengHei' #字體名稱
  Font_Exp_Gain.size = 24 #字體大小
  Font_Exp_Gain.color = (Color.new(255,174,201,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  Font_Exp_Gain.bold = true #是否粗體字
  Font_Exp_Gain.italic = true #是否斜體字
  Font_Exp_Gain.outline = true #是否繪製文字邊緣
  Font_Exp_Gain.shadow = true #是否繪製陰影
  Font_Exp_Gain.out_color = (Color.new(100,100,100,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)

  #--------------------------------------------------------------------------
  # ● 最大寬度調整
  #--------------------------------------------------------------------------
  Field_Width_Limit = 100
  
  #--------------------------------------------------------------------------
  # ● 位置調整
  #--------------------------------------------------------------------------
  Show_X_Adjust = 0 #顯示框的X座標調整
  Show_Y_Adjust = 0 #顯示框的Y座標調整
  Show_Z_Adjust = 0 #顯示框的Z座標調整
  
  
  
  
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


$lctseng_scripts[:arpg_damage_number] = "1.00"

puts "載入腳本：Lctseng - ARPG傷害數字，版本：#{$lctseng_scripts[:arpg_damage_number]}"





#==============================================================================
# ■ Lctseng_Arpg_Damage_Number_Store_Settings
#------------------------------------------------------------------------------
# 　傷害數字儲存設定
#==============================================================================
module Lctseng_Arpg_Damage_Number_Store_Settings
  #--------------------------------------------------------------------------
  # ● 傷害數字儲存物件
  #--------------------------------------------------------------------------
  def lctseng_arpg_damage_number_object
    $game_system.arpg_damage_number_object
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
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_drop_item_window_alias
    alias lctseng_for_drop_item_window_Initialize initialize # 初始化對象
    @lctseng_for_drop_item_window_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :arpg_damage_number_object            #  傷害數字物件
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    lctseng_for_drop_item_window_Initialize
    @arpg_damage_number_object  = Game_ArpgDamageNumberCollecter.new
  end
  #--------------------------------------------------------------------------
  # ● 重新讀取額外資訊，若不存在的話
  #--------------------------------------------------------------------------
  def reload_extra_data
    @arpg_damage_number_object  = Game_ArpgDamageNumberCollecter.new unless @arpg_damage_number_object
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 混入設定模組
  #--------------------------------------------------------------------------
  include Lctseng_Arpg_Damage_Number_Store_Settings
  #--------------------------------------------------------------------------
  # ● 事件顯示玩家傷害數字(以角色實例為目標)
  #--------------------------------------------------------------------------
  def show_arpg_damage_number_player(number,character = $game_player,type = 0)
    lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number,type)
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示敵人傷害數字(以角色實例為目標)
  #--------------------------------------------------------------------------
  def show_arpg_damage_number_enemy(number,character = $game_player,type = 0)
    lctseng_arpg_damage_number_object.create_enemy_damage_number_with_event(character,number,type)
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示恢復HP數字(以角色實例為目標)
  #--------------------------------------------------------------------------
  def show_arpg_recover_hp_number(number,character = $game_player)
    lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number*-1,0)
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示恢復MP數字(以角色實例為目標)
  #--------------------------------------------------------------------------
  def show_arpg_recover_mp_number(number,character = $game_player)
    lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number*-1,1)
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示增加EXP數字(以角色實例為目標)
  #--------------------------------------------------------------------------
  def show_arpg_gain_exp_number(number,character = $game_player)
    lctseng_arpg_damage_number_object.create_player_exp_number_with_character(character,number)
  end

  #--------------------------------------------------------------------------
  # ● 事件顯示玩家傷害數字(以角色ID為目標)
  #--------------------------------------------------------------------------
  def show_player_damage(number,character_id = -1,type = 0)
    character = get_character(character_id)
    number = adjust_number(number)
    if character
      if number < 0
        lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,1,2)
      else
        lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number,type)
      end

    end
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示敵人傷害數字(以角色ID為目標)
  #--------------------------------------------------------------------------
  def show_enemy_damage(number,character_id = -1,type = 0)
    character = get_character(character_id)
    number = adjust_number(number)
    if character
      if number < 0
        lctseng_arpg_damage_number_object.create_enemy_damage_number_with_event(character,1,2)
      else
        lctseng_arpg_damage_number_object.create_enemy_damage_number_with_event(character,number,type)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示恢復HP數字(以角色ID為目標)
  #--------------------------------------------------------------------------
  def show_hp(number,character_id = -1)
    character = get_character(character_id)
    if character
      lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number*-1,0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示恢復MP數字(以角色ID為目標)
  #--------------------------------------------------------------------------
  def show_mp(number,character_id = -1)
    character = get_character(character_id)
    if character
      lctseng_arpg_damage_number_object.create_player_damage_number_with_event(character,number*-1,1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 事件顯示增加EXP數字(以角色ID為目標)
  #--------------------------------------------------------------------------
  def show_exp(number,character_id = -1)
    character = get_character(character_id)
    if character
      lctseng_arpg_damage_number_object.create_player_exp_number_with_character(character,number)
    end
  end
  #--------------------------------------------------------------------------
  # ● 利用全域變數調整數值
  #--------------------------------------------------------------------------
  def adjust_number(ori_value)
    Lctseng_Arpg_Damage_Number_Settings::Number_Assign_Variable_ID_List.each do |var_id|
      if $game_variables[var_id] != 0
        value = $game_variables[var_id]
        $game_variables[var_id] = 0
        return value
      end
    end
    return ori_value
  end
  #
  
end##end class


#encoding:utf-8
#==============================================================================
# ■Game_ArpgDamageNumberCollecter
#==============================================================================

class Game_ArpgDamageNumberCollecter
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @damage_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 儲存實例，重定義使得Marshal 寫入時不會將精靈寫入檔案
  #--------------------------------------------------------------------------
  def marshal_dump
    []
  end
  #--------------------------------------------------------------------------
  # ● 讀取實例
  #--------------------------------------------------------------------------
  def marshal_load(obj)
    @damage_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_all_sprites
  end
  #--------------------------------------------------------------------------
  # ● 更新所有精靈
  #--------------------------------------------------------------------------
  def update_all_sprites
    @damage_sprites.each_with_index do|sprite,index|
      if !sprite || sprite.disposed?
        @damage_sprites.delete_at(index)
      else
        sprite.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 產生敵方傷害數字精靈 - 指定敵方角色(number: 傷害數值參數，type：傷害類型 )
  #--------------------------------------------------------------------------
  def create_enemy_damage_number_with_event(event,number,type)
    create_enemy_damage_number_with_xy(event.x,event.y,number,type)
  end
  #--------------------------------------------------------------------------
  # ● 產生敵方傷害數字精靈 - 指定地圖座標(number: 傷害數值參數，type：傷害類型 )
  #--------------------------------------------------------------------------
  def create_enemy_damage_number_with_xy(x,y,number,type)
    @damage_sprites.push(Sprite_EnemyDamageNumber.new(x,y,number,type))
  end
  #--------------------------------------------------------------------------
  # ● 產生我方傷害數字精靈 - 指定我方角色(number: 傷害數值參數，type：傷害類型 )
  #--------------------------------------------------------------------------
  def create_player_damage_number_with_event(character,number,type)
    create_player_damage_number_with_xy(character.x,character.y,number,type)
  end
  #--------------------------------------------------------------------------
  # ● 產生我方傷害數字精靈 - 指定地圖座標(number: 傷害數值參數，type：傷害類型 )
  #--------------------------------------------------------------------------
  def create_player_damage_number_with_xy(x,y,number,type)
    @damage_sprites.push(Sprite_PlayerDamageNumber.new(x,y,number,type))
  end
  #--------------------------------------------------------------------------
  # ● 產生我方經驗值數字精靈 - 指定我方角色(number: 經驗值參數 )
  #--------------------------------------------------------------------------
  def create_player_exp_number_with_character(character,number)
    create_player_exp_number_with_xy(character.x,character.y,number)
  end
  #--------------------------------------------------------------------------
  # ● 產生我方經驗值數字精靈 - 指定地圖座標(number: 經驗值參數 )
  #--------------------------------------------------------------------------
  def create_player_exp_number_with_xy(x,y,number)
    @damage_sprites.push(Sprite_ExpNumber.new(x,y,number))
  end
  #--------------------------------------------------------------------------
  # ● 強制釋放所有精靈
  #--------------------------------------------------------------------------
  def dispose_all
    @damage_sprites.compact.each {|sprite| sprite.dispose }
  end
  
  
end

#encoding:utf-8
#==============================================================================
# ■ Sprite_ArpgDamageNumber
#==============================================================================

class Sprite_ArpgDamageNumber < Sprite
  #--------------------------------------------------------------------------
  # ● 混入設定模組
  #--------------------------------------------------------------------------
  include Lctseng_Arpg_Damage_Number_Settings
  #--------------------------------------------------------------------------
  # ● 初始化對象 event :  Game_Event
  #             type特殊意涵：0：正常
  #                                      1：暴擊
  #                                      2：迴避
  #                                      3：格擋
  #--------------------------------------------------------------------------
  def initialize(x,y,number,type = 0,viewport = nil)
    super(viewport)
    @type = type
    @font = get_normal_font
    @sub_string = ''
    @wide_reserve = 0
    @flow_y = 0.0
    @main_string =  convert_to_string(number)
    @main_width = @main_string.size*@font.size * 0.75
    if @main_width > Field_Width_Limit
      @main_width = Field_Width_Limit
    end
    self.visible = false
    @fix_x = x
    @fix_y = y
    @flow_count = 60
    create_bitmap
    @total_x_adjust  = ( self.bitmap.width - @wide_reserve ) / -2  - @wide_reserve  +  Show_X_Adjust + rand(10) - 5
    @total_y_adjust =  rand(10) - 5
  end
  #--------------------------------------------------------------------------
  # ● 轉換為字串
  #--------------------------------------------------------------------------
  def convert_to_string(number)
    if number < 0
      convert_to_string_recovery(number)
    else
      convert_to_string_damage(number)
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 轉換為字串 - 處理恢復 0：回HP、1：回MP
  #--------------------------------------------------------------------------
  def convert_to_string_recovery(number)
    number = number.abs
    case @type
    when 0
      @font = Font_Recovery_Hp
      @flow_y -= @font.size
    when 1
      @font = Font_Recovery_Mp
    end
    number.to_s
  end
  #--------------------------------------------------------------------------
  # ● 轉換為字串 - 處理傷害
  #--------------------------------------------------------------------------
  def convert_to_string_damage(number)
    case @type
    when 0
      @font = get_normal_font
      number.to_s
    when 1
      @font = get_critical_font
      @sub_string = ''#"暴擊"
      @wide_reserve = @font.size * @sub_string.size 
      number.to_s
    when 2
      @font = get_miss_font
      return "迴避"
    when 3
      @font = get_block_font
      return "格擋"
    end   
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 取得普通字型物件
  #--------------------------------------------------------------------------
  def get_normal_font
    return @font if @font
  end
  #--------------------------------------------------------------------------
  # ● 取得暴擊字型物件
  #--------------------------------------------------------------------------
  def get_critical_font
    font = get_normal_font.clone
    font.color = Color.new(255,104,32)
    font.out_color = Color.new(155,0,0)
    font
  end
  #--------------------------------------------------------------------------
  # ● 取得迴避字型物件
  #--------------------------------------------------------------------------
  def get_miss_font
    font = get_normal_font.clone
    font.color = Color.new(255,255,255)
    font
  end
  #--------------------------------------------------------------------------
  # ● 取得格擋字型物件
  #--------------------------------------------------------------------------
  def get_block_font
    font = get_normal_font.clone
    font.color = Color.new(0,255,255)
    font
  end
  #--------------------------------------------------------------------------
  # ● 生成位圖
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(@wide_reserve+@main_width,@font.size)
    self.bitmap.font = @font
    main_rect = self.bitmap.rect.clone
    main_rect.x += @wide_reserve
    main_rect.width  -= @wide_reserve
    sub_rect = self.bitmap.rect.clone
    #sub_rect.x = @wide_reserve 
    sub_rect.width = @wide_reserve
    self.bitmap.draw_text(sub_rect,@sub_string, 0)
    self.bitmap.draw_text(main_rect,@main_string, 1)
    
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_visibility
    update_position
    update_fadeout
    
    
  end
  #--------------------------------------------------------------------------
  # ● 更新檢查並重繪
  #--------------------------------------------------------------------------
  def update_fadeout
    if @flow_count > 0
      @flow_y -= 0.5
      @flow_count -= 1
    else
      dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    self.x = screen_x  + @total_x_adjust
    self.y = screen_y- 30 + Show_Y_Adjust + @flow_y + @total_y_adjust
    self.z = 200 + Show_Z_Adjust
  end
  #--------------------------------------------------------------------------
  # ● 更新可視狀態
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 X 坐標
  #--------------------------------------------------------------------------
  def screen_x
    $game_map.adjust_x(@fix_x) * 32 + 16
  end
  #--------------------------------------------------------------------------
  # ● 獲取畫面 Y 坐標
  #--------------------------------------------------------------------------
  def screen_y
    $game_map.adjust_y(@fix_y) * 32 
  end

end

#encoding:utf-8
#==============================================================================
# ■ Sprite_EnemyDamageNumber
#==============================================================================

class Sprite_EnemyDamageNumber < Sprite_ArpgDamageNumber
  #--------------------------------------------------------------------------
  # ● 取得普通字型物件
  #--------------------------------------------------------------------------
  def get_normal_font
    super
    Enemy_Draw_Font
  end
end


#encoding:utf-8
#==============================================================================
# ■ Sprite_PlayerDamageNumber
#==============================================================================

class Sprite_PlayerDamageNumber < Sprite_ArpgDamageNumber
  #--------------------------------------------------------------------------
  # ● 取得普通字型物件
  #--------------------------------------------------------------------------
  def get_normal_font
    super
    Player_Draw_Font
  end
end


#encoding:utf-8
#==============================================================================
# ■ Sprite_ExpNumber
#==============================================================================

class Sprite_ExpNumber < Sprite_ArpgDamageNumber
  #--------------------------------------------------------------------------
  # ● 取得普通字型物件
  #--------------------------------------------------------------------------
  def get_normal_font
    super
    Font_Exp_Gain
  end
  #--------------------------------------------------------------------------
  # ● 轉換為字串 - 處理傷害
  #--------------------------------------------------------------------------
  def convert_to_string_damage(number)
    @sub_string = "Exp"
    @wide_reserve = (@font.size * @sub_string.size * 0.5).round
    sprintf("%+d",number)
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 混入設定模組
  #--------------------------------------------------------------------------
  include Lctseng_Arpg_Damage_Number_Store_Settings
  #--------------------------------------------------------------------------
  # ● 方法重新定義別名
  #--------------------------------------------------------------------------
  unless @lctsneg_for_arpg_alias
    alias lctseng_for_arpg_Update_for_fade update_for_fade
    alias lctseng_for_aprg_Update update
    alias lctseng_for_arpg_Terminate terminate
    @lctsneg_for_arpg_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面（消退用） - 重新定義
  #--------------------------------------------------------------------------
  def update_for_fade
    lctseng_for_arpg_Update_for_fade
    update_arpg_damage_number
  end
  #--------------------------------------------------------------------------
  # ● 更新傷害數字收集物件
  #--------------------------------------------------------------------------
  def update_arpg_damage_number
    lctseng_arpg_damage_number_object.update
  end ##end def  
  #--------------------------------------------------------------------------
  # ● 結束處理 - 重新定義
  #--------------------------------------------------------------------------
  def terminate
    dispose_damage_number_object
    lctseng_for_arpg_Terminate
  end
  #--------------------------------------------------------------------------
  # ● 釋放傷害數字物件精靈組
  #--------------------------------------------------------------------------
  def dispose_damage_number_object
    lctseng_arpg_damage_number_object.dispose_all
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面-ARPG重新定義
  #--------------------------------------------------------------------------
  def update
    lctseng_for_aprg_Update #執行原來的更新方法
    update_arpg_damage_number    
  end
  
  
end ##end class


