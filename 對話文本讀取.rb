#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 對話文本讀取 ＊

                       for RGSS3

        Ver 1.00   2014.07.14

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原為替"wer227942914(小羽貓咪)"撰寫的特製版本
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、讀取文本文字到對話框
                       二、原本文章顯示的控制符號皆可使用
                       三、自動換行功能
                       四、指令執行功能，可操作變數、開關，顯示圖片、音樂效果
            
    備註：
                      一、在文本讀取過程中請勿呼叫存檔，否則將會有錯誤發生
                      二、指令執行時，請注意必須要確定能執行的指令才輸入
                       

   更新紀錄：
    Ver 1.00 ：
    日期：2014.07.14
    摘要：一、最初版本


                       
                       

    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           1. Game_Interpreter
                           2. Game_System
                           3.Window_Message
                           
                           
                          
                        二、此腳本新定義以下類別和模組：
                           1. Lctseng::TextReader

                          

*******************************************************************************************

=end


#*******************************************************************************************
#
#   文本內容說明
#
#*******************************************************************************************

# 以 "#" 開頭的行(最左邊第一個字)是註解，以"%"開頭的是指令，會直接進入程式碼中運算
# 指令不一定是以下所舉的例子，可以是任何可執行指令
#
#『開關控制』 、 『變數控制』 
#  %$game_switches[開關編號] = true/false
#  %$game_variables[變數編號] = 數值 或者是 運算結果(例如：$game_variables[另一個變數編號] * 10)
#
#
#『停頓時間』  
#  %wait(停頓幀數)
#
#『顯示、消除圖片』  
#  %screen.pictures[圖片編號].show("圖片名字", 原點, 畫面x坐標, 畫面y坐標, x軸放大率, y軸放大率, 不透明度, 顯示方式)
#  %screen.pictures[圖片編號].erase
#
#『音效設定』 
#  %Audio.bgm_play("Audio/BGM/音樂文件名", 音量, 頻率)
#  %Audio.bgs_play("Audio/BGS/音樂文件名", 音量, 頻率)
#  %Audio.se_play("Aud-+io/ME/音樂文件名", 音量, 頻率)
#  %Audio.se_play("Audio/SE/音樂文件名", 音量, 頻率)
#  %Audio.bgm_stop、Audio.bgs_stop、Audio.me_stop、Audio.se_stop
#
#
# 『顯示位置』 
#
# %pos = 位置(0上，1中，2下)，效用持續直到更換為止(或者是文本結束)
#
# 『背景樣式』 
#
# %msg_bg = 樣式(0正常，1暗化，2透明)，效用持續直到更換為止(或者是文本結束)
#
#


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
$lctseng_scripts[:text_reader] = "1.00"

puts "載入腳本：Lctseng - 對話文本讀取，版本：#{$lctseng_scripts[:text_reader]}"



#encoding:utf-8
#==============================================================================
# ■ Lctseng::TextReader
#------------------------------------------------------------------------------
# 　文本直譯、解釋模組
#==============================================================================

module Lctseng
module TextReader
  
  #--------------------------------------------------------------------------
  # ● 迭代每一行，無處理
  #--------------------------------------------------------------------------
  def self.iterate_each_line(filename)
    File.open("Data/Script/#{filename}.txt","r") do |file|
      head = false
      file.each_line do |line|
        if !head
          puts "忽略：#{line}"
          head = true
          next
        else
          yield line
        end
        
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 迭代每一行，有處理文字，忽略註解與空白行
  # 回傳格式：
  # :type ： 文本(:text)、指令(:command)
  # :content：內容字串
  #--------------------------------------------------------------------------
  def self.iterate_each_line_with_parse(filename)
    iterate_each_line(filename) do |line|
      #puts "處理：#{line}"
      if line.chomp.empty?
        puts "偵測到空行，忽略"
        next
      else
        first = line[0,1]
        #puts "開頭字元：#{first}"
        result = {}
        case first
        when "#"
          puts "註解：#{line}"
          next
        when "%"
          result[:type] = :command
          result[:content] = line[1,line.length]
          puts "指令：#{result[:content]}"
        else
          result[:type] = :text
          result[:content] = line
          puts "文本：#{result[:content]}"
        end
        
        
        yield result
      end
    end
  end


  
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
  # ● 開始文本讀取
  #--------------------------------------------------------------------------
  def start_text_reader(filename)
    return if $game_system.text_reader_active # 防止遞迴
    $game_system.text_reader_active = true
    pos = 0
    msg_bg = 0
    Lctseng::TextReader.iterate_each_line_with_parse(filename) do |result|
      case result[:type]
      when :text
        show_text_message(result[:content],pos,msg_bg)
      when :command
        eval(result[:content])
      end
    end
    $game_system.text_reader_active = false
  end
  #--------------------------------------------------------------------------
  # ● 顯示文字
  #--------------------------------------------------------------------------
  def show_text_message(text,pos,msg_bg)
    $game_message.background = msg_bg
    $game_message.position = pos
    $game_message.add(text)
    wait_for_message
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
  # ● 文字的處理，加入換行操作
  #     c    : 文字
  #     text : 繪制處理中的字符串緩存（字符串可能會被修改）
  #     pos  : 繪制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\r"   # 回車
      super
    when "\n"   # 換行
      super
    when "\f"   # 翻頁
      super
    when "\e"   # 控制符
      super
    else        # 普通文字
      process_normal_character(c, text , pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 處理普通文字
  #--------------------------------------------------------------------------
  alias text_read_process_normal_character process_normal_character unless $@
  #--------------------------------------------------------------------------
  def process_normal_character(c,text ,  pos)
    text_width = text_size(c).width
    if contents.width - pos[:x] < text_width
      process_new_line(text,pos)
    end
    text_read_process_normal_character(c,  pos)
  end
  #--------------------------------------------------------------------------
  # ● 實際內容寬度
  #--------------------------------------------------------------------------
  def real_width
    return contents_width
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
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :text_reader_active            # 是否已啟用文字讀取模式
end

