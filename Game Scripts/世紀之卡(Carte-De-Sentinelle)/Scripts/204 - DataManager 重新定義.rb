#encoding:utf-8
#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　數據庫和游戲實例的管理器。所有在游戲中使用的全局變量都在這里初始化。
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # ★ 方法重新定義
  #--------------------------------------------------------------------------
  unless @lctseng_for_save_ex_alias
    class << self 
      alias lctseng_savefile_max savefile_max # 存檔文件的最大數
      alias lctseng_make_save_header make_save_header # 生成存檔的標頭數據
      alias lctseng_for_save_ex_Save_game_without_rescue save_game_without_rescue # 生成存檔的標頭數據
    end
    @lctseng_for_save_ex_alias = true
  end
  #--------------------------------------------------------------------------
  # ● 最大自動存檔
  #--------------------------------------------------------------------------
  def self.max_auto
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 取得現實時間字串
  #--------------------------------------------------------------------------
  def self.gain_time_string
    time = Time.new
    return time.strftime("%Y年%m月%d日(%a)%X ") 
  end
  #--------------------------------------------------------------------------
  # ● 取得劇本名稱
  #--------------------------------------------------------------------------
  def self.story_name
    case $game_variables[20]
    when 1
      return "斐恩&亞莎"
    when 2
      return "赤琥&蒼玉"
    when 3
      return "洛倫&瑪雅"
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成存檔的標頭數據  - 重新定義
  #--------------------------------------------------------------------------
  def self.make_save_header 
    header = {}
    header[:names] = story_name
    header[:playtime_s] = $game_system.playtime_s
    header[:time_log] = gain_time_string
    header[:map_name] = $game_map.display_name
    header[:screen_snap] = DataManager.save_bitmap
    header
  end
  #--------------------------------------------------------------------------
  # ● 檔案樹狀圖遞迴列印
  #--------------------------------------------------------------------------
  def self.file_tree_recursion_print(obj,level = 0)
    if level > 80
      puts "遞迴過深！"
      return
    end
    puts  " "*level*5 + "#{obj.class}:的實例變數："
    obj.instance_variables.each do |varname|
      ivar = obj.instance_variable_get(varname)
      puts  " "*level*5 + "#{varname} is a #{ivar.class}"
      file_tree_recursion_print(ivar,level+1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 執行自動存檔
  #--------------------------------------------------------------------------
  def self.execute_auto_save
    # 移除最底端的自動存檔格
    delete_save_file(max_auto-1)
    # 自動存檔格下移
    shift_savefile_name_by_index(0,max_auto-1)
    # 儲存遊戲
    save_game(0)
  end
  #--------------------------------------------------------------------------
  # ● 存檔格下移，指定閉區間
  #--------------------------------------------------------------------------
  def self.shift_savefile_name_by_index(from,to)
    Range.new(from,to).to_a.reverse.each do |index|
      begin
        File.rename(make_filename(index),make_filename(index+1))
      rescue
      end
    end
  end


end
