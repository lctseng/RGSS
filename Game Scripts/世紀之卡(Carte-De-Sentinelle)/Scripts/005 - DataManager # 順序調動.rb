#encoding:utf-8
#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　數據庫和游戲實例的管理器。所有在游戲中使用的全局變量都在這里初始化。
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # ● 模塊的實例變量
  #--------------------------------------------------------------------------
  @last_savefile_index = 0                # 最后訪問的存檔文件
  #--------------------------------------------------------------------------
  # ● 初始化模塊
  #--------------------------------------------------------------------------
  def self.init
    @last_savefile_index = 0
    load_database
    create_game_objects
    setup_battle_test if $BTEST
  end
  #--------------------------------------------------------------------------
  # ● 讀取數據庫
  #--------------------------------------------------------------------------
  def self.load_database
    if $BTEST
      load_battle_test_database
    else
      load_normal_database
      check_player_location
    end
  end
  #--------------------------------------------------------------------------
  # ● 讀取普通的數據庫
  #--------------------------------------------------------------------------
  def self.load_normal_database
    $data_actors        = load_data("Data/Actors.rvdata2")
    $data_classes       = load_data("Data/Classes.rvdata2")
    $data_skills        = load_data("Data/Skills.rvdata2")
    $data_items         = load_data("Data/Items.rvdata2")
    $data_weapons       = load_data("Data/Weapons.rvdata2")
    $data_armors        = load_data("Data/Armors.rvdata2")
    $data_enemies       = load_data("Data/Enemies.rvdata2")
    $data_troops        = load_data("Data/Troops.rvdata2")
    $data_states        = load_data("Data/States.rvdata2")
    $data_animations    = load_data("Data/Animations.rvdata2")
    $data_tilesets      = load_data("Data/Tilesets.rvdata2")
    $data_common_events = load_data("Data/CommonEvents.rvdata2")
    $data_system        = load_data("Data/System.rvdata2")
    $data_mapinfos      = load_data("Data/MapInfos.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 讀取戰斗測試用的數據庫
  #--------------------------------------------------------------------------
  def self.load_battle_test_database
    $data_actors        = load_data("Data/BT_Actors.rvdata2")
    $data_classes       = load_data("Data/BT_Classes.rvdata2")
    $data_skills        = load_data("Data/BT_Skills.rvdata2")
    $data_items         = load_data("Data/BT_Items.rvdata2")
    $data_weapons       = load_data("Data/BT_Weapons.rvdata2")
    $data_armors        = load_data("Data/BT_Armors.rvdata2")
    $data_enemies       = load_data("Data/BT_Enemies.rvdata2")
    $data_troops        = load_data("Data/BT_Troops.rvdata2")
    $data_states        = load_data("Data/BT_States.rvdata2")
    $data_animations    = load_data("Data/BT_Animations.rvdata2")
    $data_tilesets      = load_data("Data/BT_Tilesets.rvdata2")
    $data_common_events = load_data("Data/BT_CommonEvents.rvdata2")
    $data_system        = load_data("Data/BT_System.rvdata2")
  end
  #--------------------------------------------------------------------------
  # ● 檢查玩家初始位置
  #--------------------------------------------------------------------------
  def self.check_player_location
    if $data_system.start_map_id == 0
      msgbox(Vocab::PlayerPosError)
      exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成各種游戲對象
  #--------------------------------------------------------------------------
  def self.create_game_objects
    $game_actors        = Game_Actors.new
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_timer         = Game_Timer.new
    $game_message       = Game_Message.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
  end
  #--------------------------------------------------------------------------
  # ● 設置新游戲
  #--------------------------------------------------------------------------
  def self.setup_new_game
    create_game_objects
    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    Graphics.frame_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 設置戰斗測試
  #--------------------------------------------------------------------------
  def self.setup_battle_test
    $game_party.setup_battle_test
    BattleManager.setup($data_system.test_troop_id)
    BattleManager.play_battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● 判定存檔文件是否存在
  #--------------------------------------------------------------------------
  def self.save_file_exists?
    !Dir.glob('Save*.rvdata2').empty?
  end
  #--------------------------------------------------------------------------
  # ● 存檔文件的最大數
  #--------------------------------------------------------------------------
  def self.savefile_max
    return 6
  end
  #--------------------------------------------------------------------------
  # ● 生成文件名
  #     index : 文件索引
  #--------------------------------------------------------------------------
  def self.make_filename(index)
    sprintf("Save%02d.rvdata2", index + 1)
  end
  #--------------------------------------------------------------------------
  # ● 執行存檔
  #--------------------------------------------------------------------------
  def self.save_game(index)
    begin
      save_game_without_rescue(index)
    rescue
      delete_save_file(index)
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 執行讀檔
  #--------------------------------------------------------------------------
  def self.load_game(index)
    load_game_without_rescue(index) rescue false
  end
  #--------------------------------------------------------------------------
  # ● 讀取存檔的頭數據
  #--------------------------------------------------------------------------
  def self.load_header(index)
    load_header_without_rescue(index) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 執行存檔（沒有錯誤處理）
  #--------------------------------------------------------------------------
  def self.save_game_without_rescue(index)
    File.open(make_filename(index), "wb") do |file|
      $game_system.on_before_save
      Marshal.dump(make_save_header, file)
      Marshal.dump(make_save_contents, file)
      @last_savefile_index = index if index < 50 # TODO：修改
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 執行讀檔（沒有錯誤處理）
  #--------------------------------------------------------------------------
  def self.load_game_without_rescue(index)
    File.open(make_filename(index), "rb") do |file|
      Marshal.load(file)
      extract_save_contents(Marshal.load(file))
      if index != CardBattle::BATTLE_SAVE_INDEX &&  $game_system.battle_only
        raise("檔案格式損壞")
      end
      reload_map_if_updated
      @last_savefile_index = index
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 讀取存檔的頭數據（沒有錯誤處理）
  #--------------------------------------------------------------------------
  def self.load_header_without_rescue(index)
    File.open(make_filename(index), "rb") do |file|
      return Marshal.load(file)
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 刪除存檔文件
  #--------------------------------------------------------------------------
  def self.delete_save_file(index)
    File.delete(make_filename(index)) rescue nil
  end
  #--------------------------------------------------------------------------
  # ● 生成存檔的頭數據
  #--------------------------------------------------------------------------
  def self.make_save_header
    header = {}
    header[:characters] = $game_party.characters_for_savefile
    header[:playtime_s] = $game_system.playtime_s
    header
  end
  #--------------------------------------------------------------------------
  # ● 生成存檔內容
  #--------------------------------------------------------------------------
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player
    contents
  end
  #--------------------------------------------------------------------------
  # ● 展開存檔內容
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    $game_system        = contents[:system]
    $game_timer         = contents[:timer]
    $game_message       = contents[:message]
    $game_switches      = contents[:switches]
    $game_variables     = contents[:variables]
    $game_self_switches = contents[:self_switches]
    $game_actors        = contents[:actors]
    $game_party         = contents[:party]
    $game_troop         = contents[:troop]
    $game_map           = contents[:map]
    $game_player        = contents[:player]
  end
  #--------------------------------------------------------------------------
  # ● 如果數據已更新則重載地圖
  #--------------------------------------------------------------------------
  def self.reload_map_if_updated
    if $game_system.version_id != $data_system.version_id
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
      $game_player.make_encounter_count
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取存檔文件時間戳
  #--------------------------------------------------------------------------
  def self.savefile_time_stamp(index)
    File.mtime(make_filename(index)) rescue Time.at(0)
  end
  #--------------------------------------------------------------------------
  # ● 獲取“最后更新的存檔文件”的索引
  #--------------------------------------------------------------------------
  def self.latest_savefile_index
    savefile_max.times.max_by {|i| savefile_time_stamp(i) }
  end
  #--------------------------------------------------------------------------
  # ● 獲取“最后訪問的存檔文件”的索引
  #--------------------------------------------------------------------------
  def self.last_savefile_index
    @last_savefile_index
  end
end
