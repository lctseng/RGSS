#encoding:utf-8

=begin
#*******************************************************************************************
#
#   ＊ 對話名稱與立繪 ＊
#
#                       for RGSS3
#
#        Ver 1.10   2014.03.22
#
#   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
#   原文發表於：巴哈姆特RPG製作大師哈拉版
#
#   轉載請保留此標籤
#
#   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
#
#   主要功能：
#                       一、提供將原本內建的對話臉圖放大的功能
#                       二、可以指定說話者的名稱，擁有額外的視窗顯示
#                       三、對話打字聲效與文字出現速度調整
#
#
#
#   更新紀錄：
#    Ver 1.00 ：
#    日期：2013.08.10
#    摘要：一、最初版本
#

#    Ver 1.10 ：
#    日期：2014.03.22
#    摘要：一、立繪可以在右邊出現，指定用的關鍵字為 \BFR
                          但是位於右邊的對話名稱框將不再調整


#
#    撰寫摘要：一、此腳本修改或重新定義以下類別或模組：
#                          1.Cache
#                          2.Game_Message
#                          3.Window_Message
#
#                          二、此腳本新定義以下類別和模組：
#                          1.Sprite_MessageFace
#                          2.Window_MessageNameBlock
#                          3.Window_LeftMessageNameBlock
#                          4.Window_RightMessageNameBlock
#
#                          三、此腳本定義了以下可供修改設定的模組：
#                          1.Lctseng_MessageNameBlock_Setting
#                          2.Lctseng_Message_Face_Settings
#
#*******************************************************************************************
=end

module Lctseng_MessageNameBlock_Setting
  #--------------------------------------------------------------------------
  # ● 文字寬度，用於名牌中每一個字要配多少空間
  #--------------------------------------------------------------------------
  Width_Per_Word = 25
  #--------------------------------------------------------------------------
  # ● 視窗本身透明度
  #--------------------------------------------------------------------------
  Window_Opacity = 200
  #--------------------------------------------------------------------------
  # ● 左視窗位移
  #--------------------------------------------------------------------------
  Window_Left_Shift_X = 0
  Window_Left_Shift_Y = 0
  #--------------------------------------------------------------------------
  # ● 右視窗位移
  #--------------------------------------------------------------------------
  Window_Right_Shift_X = 0
  Window_Right_Shift_Y = 0
  
end


#==============================================================================
# ■ Lctseng_Message_Face_Settings
#------------------------------------------------------------------------------
# 　對話立繪設定
#==============================================================================
module Lctseng_Message_Face_Settings
  #--------------------------------------------------------------------------
  # ● 大臉圖XY調整，基準點為左下角
  #--------------------------------------------------------------------------
  Big_Face_Adjust_X = 10  
  Big_Face_Adjust_Y = -5
  #--------------------------------------------------------------------------
  # ● 大臉圖文字X位移修正，原本值為圖像寬度，負值則是左移
  #--------------------------------------------------------------------------
  Big_Face_X_Shift = 0

  
end


#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************


#encoding:utf-8
#==============================================================================
# ■ Cache
#------------------------------------------------------------------------------
#  處理載入圖像，建立/儲保 Bitmap 物件。為加快載入速度和節省內存，
#  此模塊將建立的 bitmap 物件保存在內部哈希表中，令程序要再次處理
# 　相同的圖像時能快速讀取。
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # ● 獲取“臉圖立繪”圖像
  #--------------------------------------------------------------------------
  def self.big_face(filename)
    load_bitmap("Graphics/Faces/Large/", filename)
  end
end




#encoding:utf-8
#==============================================================================
# ■ Game_Message
#------------------------------------------------------------------------------
# 　處理信息窗口狀態、文字顯示、選項等的類。本類的實例請參考 $game_message 。
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :left_name
  attr_reader   :right_name
  attr_reader   :low_speed
  attr_reader   :disable_sound
  #--------------------------------------------------------------------------
  # ● 清除 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_message_name_block_Clear clear
  #--------------------------------------------------------------------------
  def clear
    lctseng_for_message_name_block_Clear
    @left_name = ''
    @right_name = ''
    @left_name_id = 0
    @right_name_id = 0
    @low_speed = 0
    @disable_sound = false
  end
  #--------------------------------------------------------------------------
  # ● 添加內容 - 重新定義
  #--------------------------------------------------------------------------
  alias lctseng_for_message_name_block_Add add
  #--------------------------------------------------------------------------
  def add(text)
    lctseng_for_message_name_block_Add(match_name(text))
  end
  #--------------------------------------------------------------------------
  # ● 匹配出對話者名字並回傳刪除名字之後的字串、此外也處理特殊指令
  #--------------------------------------------------------------------------
  def match_name(original_text)
    text = original_text.clone
    ## 處理普通名稱
    text =~ /<Name_Left=(.*)>/  
    @left_name = $1 if $1 
    text =~ /<Name_Right=(.*)>/  
    @right_name = $1 if $1
    ## 處理指定ID名稱
    text =~ /<Name_Left_ID=(\d+)>/i
    @left_name_id = $1.to_i
    @left_name = $game_actors[@left_name_id].name if $game_actors[@left_name_id]
    text =~ /<Name_Right_ID=(\d+)>/i
    @right_name_id = $1.to_i
    @right_name = $game_actors[@right_name_id].name if $game_actors[@right_name_id]
    ## 處理領隊名稱
    actor = $game_player.actor
    if actor
      if text =~ /<Name_Right_Leader>/ 
        @right_name = actor.name
      end
      if text =~ /<Name_Left_Leader>/ 
        @left_name = actor.name
      end
    end
    ## 處理特殊指令：緩慢顯示
    if text =~ /<Show_Wait=(\d+)>/i 
      @low_speed = $1.to_i
    end
    ## 處理特殊指令：關閉打字音效
    if text =~ /<Disable_Sound>/i 
      @disable_sound = true
    end
    ## 刪除文字
    begin
      text["<Disable_Sound>"]= '' 
    rescue
    end
    begin
      text[sprintf("<Show_Wait=%d>",@low_speed)]= '' 
    rescue
    end
    begin
      text[sprintf("<Name_Left=%s>",@left_name)]= '' 
    rescue
    end
    begin
     text[sprintf("<Name_Right=%s>",@right_name)]= '' 
    rescue
    end
    begin
     text[sprintf("<Name_Left_ID=%d>",@left_name_id)]= '' 
    rescue
    end
    begin
     text[sprintf("<Name_Right_ID=%d>",@right_name_id)]= '' 
    rescue
    end
    begin
      text["<Name_Right_Leader>"]= '' 
    rescue
    end
    begin
      text["<Name_Left_Leader>"]= '' 
    rescue
    end
    text
  end
end



#encoding:utf-8
#==============================================================================
# ■ Game_Message
#------------------------------------------------------------------------------
# 　處理信息窗口狀態、文字顯示、選項等的類。本類的實例請參考 $game_message 。
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor   :need_big_face # 是否需要繪製大臉圖的標誌
  attr_accessor   :face_right # 是否在右邊
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_face_ex_alias_at_Game_Message
    alias lctseng_for_face_ex_at_Game_Message_for_Clear clear # 清除
    alias lctseng_for_face_ex_at_Game_Message_for_Add add # 添加內容
    @lctseng_for_face_ex_alias_at_Game_Message = true
  end
  #--------------------------------------------------------------------------
  # ● 清除 - 重新定義
  #--------------------------------------------------------------------------
  def clear(*args,&block)
    lctseng_for_face_ex_at_Game_Message_for_Clear(*args,&block)
    @need_big_face = false
    @face_right = false
    #puts "已重置立繪要求狀態"
  end
  #--------------------------------------------------------------------------
  # ● 添加內容 - 重新定義
  #--------------------------------------------------------------------------
  def add(text)
    lctseng_for_face_ex_at_Game_Message_for_Add(process_extra(text))
  end
  #--------------------------------------------------------------------------
  # ● 處理額外控制字元
  #--------------------------------------------------------------------------
  def process_extra(original_text)
    text = original_text.clone
    if text =~ /\BFR/
      #puts "已偵測到立繪要求"
      @need_big_face = true
      @face_right = true
    end
    
    ## 刪除文字
    begin
      text['\BFR']= '' 
    rescue
    end
    
    
    if text =~ /\BF/
      #puts "已偵測到立繪要求"
      @need_big_face = true
    end
    
    ## 刪除文字
    begin
      text['\BF']= '' 
    rescue
    end
    
    return text
  end
end



#encoding:utf-8
#==============================================================================
# ■ Sprite_MessageFace
#==============================================================================

class Sprite_MessageFace < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 加入設定模組
  #--------------------------------------------------------------------------
  include Lctseng_Message_Face_Settings
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_accessor :right_align
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(message_window,viewport = nil)
    super(viewport)
    @message_window = message_window
    @bitmap_visible = false
    self.z = 300
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 處理產生立繪，利用檔名與索引
  #--------------------------------------------------------------------------
  def process_big_face_by_name_and_index(name,index,right_align = false)
    self.bitmap = Cache.big_face(process_real_filename(name,index))
    self.oy = self.bitmap.height
    if right_align
      @right_align = true
      self.x = @message_window.x + @message_window.width + Big_Face_Adjust_X - self.bitmap.width
    else
      @right_align = false
      self.x = @message_window.x + Big_Face_Adjust_X
    end
    self.y = @message_window.y + @message_window.height + Big_Face_Adjust_Y
    @bitmap_visible = true
  end
  #--------------------------------------------------------------------------
  # ● 產生真正檔名
  #--------------------------------------------------------------------------
  def process_real_filename(name,index)
    return sprintf("%s_%d",name,index)
  end
  #--------------------------------------------------------------------------
  # ● 清除圖像
  #--------------------------------------------------------------------------
  def clear_face
    self.bitmap = nil
    @bitmap_visible = false
    @right_align = false
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    update_visibility
  end
  #--------------------------------------------------------------------------
  # ● 更新可視度
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = @bitmap_visible&&@message_window.open?
  end
  #--------------------------------------------------------------------------
  # ● 文字位移量
  #--------------------------------------------------------------------------
  def text_shift
    self.bitmap ? self.width + Big_Face_X_Shift  : 0
  end
end





#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　顯示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
#~   #--------------------------------------------------------------------------
#~   # ● 混入設定模組
#~   #--------------------------------------------------------------------------
#~   include Lctseng_MessageNameBlock_Setting
  #--------------------------------------------------------------------------
  # ● 方法重新定義別名
  #--------------------------------------------------------------------------
  unless @lctsneg_for_name_block_alias
    alias lctseng_for_message_name_block_Create_all_windows create_all_windows # 生成所有窗口
    alias lctseng_for_message_name_block_Dispose_all_windows dispose_all_windows # 釋放所有窗口
    alias lctseng_for_message_name_block_Update_all_windows update_all_windows # 更新所有窗口
    alias lctseng_for_message_name_block_Update_placement update_placement # 更新窗口的位置
    alias lctseng_for_message_name_block_Process_all_text process_all_text # 處理所有內容
    alias lctseng_for_message_name_block_Close_and_wait close_and_wait # 關閉窗口并等待窗口關閉完成
    alias lctseng_for_message_plus_name_block_Process_normal_character process_normal_character # 普通文字的處理
    @lctsneg_for_name_block_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 生成所有窗口 - 重新定義
  #--------------------------------------------------------------------------
  def create_all_windows
    lctseng_for_message_name_block_Create_all_windows
    @name_window_left = Window_LeftMessageNameBlock.new(self.x,0,self)
    @name_window_right =  Window_RightMessageNameBlock.new(window_width - 180 ,0,self)
  end
  #--------------------------------------------------------------------------
  # ● 釋放所有窗口 - 重新定義
  #--------------------------------------------------------------------------
  def dispose_all_windows
    lctseng_for_message_name_block_Dispose_all_windows
    @name_window_left.dispose
    @name_window_right.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新所有窗口 - 重新定義
  #--------------------------------------------------------------------------
  def update_all_windows
    lctseng_for_message_name_block_Update_all_windows
    @name_window_left.update
    @name_window_right.update
    @name_window_left.x = name_window_x
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的位置 - 重新定義
  #--------------------------------------------------------------------------
  def update_placement
    lctseng_for_message_name_block_Update_placement
    @name_window_left.y = self.y - fitting_height(1)  +  Lctseng_MessageNameBlock_Setting::Window_Left_Shift_Y
    @name_window_right.y = self.y - fitting_height(1) + Lctseng_MessageNameBlock_Setting::Window_Right_Shift_Y
  end
  #--------------------------------------------------------------------------
  # ● 處理所有內容 - 重新定義
  #--------------------------------------------------------------------------
  def process_all_text
    
    lctseng_for_message_name_block_Process_all_text
    
  end
  #--------------------------------------------------------------------------
  # ● 處理名字框顯示
  #--------------------------------------------------------------------------
  def process_name_window
    @name_window_left.x = name_window_x
    
    if $game_message.left_name != ''
      @name_window_left.set_name($game_message.left_name)
      @name_window_left.show#open 
    else
      @name_window_left.hide#close
    end
    if $game_message.right_name != ''
      @name_window_right.set_name($game_message.right_name)
      @name_window_right.show#open 
    else
      @name_window_right.hide#close
    end
  end
  #--------------------------------------------------------------------------
  # ● 關閉窗口并等待窗口關閉完成 - 重新定義
  #--------------------------------------------------------------------------
  def close_and_wait
    @name_window_left.hide
    @name_window_right.hide
    #@name_window_left.close
    #@name_window_right.close
    lctseng_for_message_name_block_Close_and_wait
  end
  #--------------------------------------------------------------------------
  # ● 普通文字的處理 - 重新定義
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    if $game_message.low_speed > 0
      super
      process_low_speed
    else
      lctseng_for_message_plus_name_block_Process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理特殊慢速顯示
  #--------------------------------------------------------------------------
  def process_low_speed
    wait($game_message.low_speed)
    Audio.se_play("Audio/SE/Typing") if !$game_message.disable_sound rescue false
  end
end




#encoding:utf-8
#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　顯示文字信息的窗口。
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_face_ex_alias_at_Window_Message
    alias lctseng_for_face_ex_at_Window_Message_for_Initialize initialize # 初始化對象
    alias lctseng_for_face_ex_at_Window_Message_for_Dispose dispose # 釋放
    alias lctseng_for_face_ex_at_Window_Message_for_Update update # 更新畫面
    alias lctseng_for_face_ex_at_Window_Message_for_New_page new_page # 翻頁處理
    #alias lctseng_for_face_ex_at_Window_Message_for_
    @lctseng_for_face_ex_alias_at_Window_Message = true
  end
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  def initialize(*args,&block)
    lctseng_for_face_ex_at_Window_Message_for_Initialize(*args,&block)
    create_face_sprite
  end
  #--------------------------------------------------------------------------
  # ● 建立臉圖精靈
  #--------------------------------------------------------------------------
  def create_face_sprite
    @face_sprite = Sprite_MessageFace.new(self,self.viewport)
  end
  #--------------------------------------------------------------------------
  # ● 釋放 - 重新定義
  #--------------------------------------------------------------------------
  def dispose(*args,&block)
    lctseng_for_face_ex_at_Window_Message_for_Dispose(*args,&block)
    dispose_face_sprite
  end
  #--------------------------------------------------------------------------
  # ● 釋放臉圖精靈
  #--------------------------------------------------------------------------
  def dispose_face_sprite
    @face_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 - 重新定義
  #--------------------------------------------------------------------------
  def update(*args,&block)
    lctseng_for_face_ex_at_Window_Message_for_Update(*args,&block)
    update_face_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新臉圖精靈
  #--------------------------------------------------------------------------
  def update_face_sprite
    @face_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 獲取換行位置 - 修改定義
  #--------------------------------------------------------------------------
  def new_line_x
    if $game_message.face_name.empty? || @face_sprite.right_align
      return 0
    else
      if @big_face 
        return @face_sprite.text_shift
      else
        return 112
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取名稱框位置
  #--------------------------------------------------------------------------
  def name_window_x
    if $game_message.face_name.empty?
      return 0
    else
      if @big_face && !@face_sprite.right_align
        return @face_sprite.text_shift
      else
        return 0
      end
    end
  end  
  #--------------------------------------------------------------------------
  # ● 翻頁處理 - 修改定義
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    @name_window_left.hide
    @name_window_right.hide
    contents.clear
    @face_sprite.clear_face
    @big_face = false
    if $game_message.need_big_face
      $game_message.need_big_face = false
      @big_face = true
      @face_sprite.process_big_face_by_name_and_index($game_message.face_name, $game_message.face_index,$game_message.face_right)
    else
      draw_face($game_message.face_name, $game_message.face_index, 0, 0)
    end
    process_name_window
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
end




#==============================================================================
# ■ Window_MessageNameBlock
#==============================================================================


class Window_MessageNameBlock< Window_Base  
  #--------------------------------------------------------------------------
  # ● 實例變數
  #--------------------------------------------------------------------------
  attr_reader :name
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(x,y,message_window,name = '')          #初始化
    super(x,y,0,fitting_height(1))   #視窗大小（X座標, Y座標 , 寬度, 高度） 
    self.z = 210#message_window.z 
    @content_width = 0
    @name = name
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 設定名字
  #--------------------------------------------------------------------------
  def set_name(text)
    if text != @name
      @name = text
      @content_width = text_size(text).width + standard_padding #name.length*Lctseng_MessageNameBlock_Setting::Width_Per_Word
      self.width =  @content_width + standard_padding * 2
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.dispose
    width = @content_width > 0 ? @content_width : 1
    self.contents = Bitmap.new(width , contents_height)
  end##end def
end
  

#==============================================================================
# ■ Window_LeftMessageNameBlock
#==============================================================================


class Window_LeftMessageNameBlock< Window_MessageNameBlock
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(x,y,msg_window,name = '')          #初始化
    super(x,y,msg_window,name)   #視窗大小（X座標, Y座標 , 寬度, 高度） 
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_text(0,0,  contents.width , line_height  , @name) #繪製文字，
  end##end def
end
  

#==============================================================================
# ■ Window_RightMessageNameBlock
#==============================================================================


class Window_RightMessageNameBlock< Window_MessageNameBlock
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(x,y,msg_window,name = '')          #初始化
    super(x,y,msg_window,name)   #視窗大小（X座標, Y座標 , 寬度, 高度） 
    @msg_window = msg_window
    self.x = msg_window.width - self.width
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    super
    self.x = @msg_window.width - self.width if @msg_window
    draw_text(0,0, contents.width , line_height  , @name,2) #繪製文字，
  end##end def
end
  


