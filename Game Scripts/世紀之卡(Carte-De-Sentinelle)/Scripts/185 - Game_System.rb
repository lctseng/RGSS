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
  attr_accessor :disable_message_continue # 是否禁止訊息繼續
  attr_accessor :battle_only # 是否在戰鬥中存檔的標記
  attr_accessor :scene_rollback
  attr_reader :player_card_set # 玩家的卡牌組
  attr_reader :enemy_card_set # 敵人的卡牌組
  attr_reader :battle_result # 戰鬥結果
  #--------------------------------------------------------------------------
  # ● 初始化對象 - 重新定義
  #--------------------------------------------------------------------------
  alias card_battle_GameSystem_initialize initialize unless $!
  #--------------------------------------------------------------------------
  def initialize(*args,&block)
    card_battle_GameSystem_initialize(*args,&block)
    @player_card_set = CardBattle::Game_PlayerCardSet.new
    @enemy_card_set = CardBattle::Game_EnemyCardSet.new
    @battle_result = CardBattle::Game_BattleResult.new
    @enemy_id_list = []
    @disable_message_continue = false
    @scene_rollback = 0
    @battle_only = false
  end
  #--------------------------------------------------------------------------
  # ● 下一個敵人ID
  #--------------------------------------------------------------------------
  def next_enemy_id
    id = @enemy_id_list.shift
    if id
      return id
    else
      return 0
    end
  end
end
