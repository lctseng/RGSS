#encoding:utf-8
=begin



   ＊ Lctseng - 更改遊戲標題＊

                       for RGSS3

        Ver 1.0.0   2016.07.12

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   原文發表於：巴哈姆特RPG製作大師哈拉版

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123
   完整腳本程式碼：https://github.com/lctseng/RGSS


   主要功能：
                       一、於遊戲中更改遊戲標題，於下次遊戲時生效
                       二、變更是永久性的，不同遊戲間會共用修改後的標題

   更新紀錄：
    Ver 1.0.0 ：
    日期：2016.07.12
    摘要：一、最初版本




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
_sym = :change_game_title
$lctseng_scripts[_sym] = "1.0.0"

puts "載入腳本：Lctseng - 更改遊戲標題，版本：#{$lctseng_scripts[_sym]}"



module Lctseng
  #==============================================================================
  # ■ Win32
  #------------------------------------------------------------------------------
  # 　Win32API部分腳本
  #==============================================================================
  module Win32
    GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
    WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')
    MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
    WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  end
  #==============================================================================
  # ■ Ini
  #------------------------------------------------------------------------------
  # 　Ini檔案控制腳本
  #==============================================================================
  module Ini
    #--------------------------------------------------------------------------
    # ● INI檔案名稱
    #--------------------------------------------------------------------------
    INI_FILENAME = './Game.ini'
    #--------------------------------------------------------------------------
    # ● 讀取INI內容
    #--------------------------------------------------------------------------
    def self.load(section, key)
      Win32::GetPrivateProfileInt.call(section, key, '', INI_FILENAME)
    end
    #--------------------------------------------------------------------------
    # ● 儲存資料至  INI
    #--------------------------------------------------------------------------
    def self.save(section, key, value)
      Win32::WritePrivateProfileString.call(section, key, value, INI_FILENAME) != 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 文字格式轉換：轉為INI的文字格式
  #--------------------------------------------------------------------------
  def self.to_ini_charset(text)
    temp = "\0" * Win32::MultiByteToWideChar.call(65001, 0, text, -1, 0, 0)
    Win32::MultiByteToWideChar.call(65001, 0, text, -1, temp, temp.size)
    text = temp
    temp = "\0" * Win32::WideCharToMultiByte.call(0, 0, text, -1, 0, 0, 0, 0)
    Win32::WideCharToMultiByte.call(0, 0, text, -1, temp, temp.size, 0, 0)
    temp
  end
  #--------------------------------------------------------------------------
  # ● 更改遊戲標題
  #--------------------------------------------------------------------------
  def self.set_game_title(str)
    # Save to Data/System
    $data_system.game_title = str
    save_data($data_system, "Data/System.rvdata2")
    # Save to Game.ini
    Ini.save("Game","Title",to_ini_charset(str))
  end
end
